require 'rqrcode_png'

module MnoEnterprise
  class User < BaseResource
    include MnoEnterprise::Concerns::Models::IntercomUser
    extend Devise::Models
    # include ActiveModel::Model
    include ActiveModel::Conversion
    include ActiveModel::AttributeMethods
    include ActiveModel::Validations

    INCLUDED_DEPENDENCIES = %i(deletion_requests organizations orga_relations dashboards teams sub_tenant)
    SUPPORT_ROLE = 'support'
    STAFF_ROLE = 'staff'
    ADMIN_ROLE = 'admin'

    # ids
    property :id
    property :uid, type: :string

    # timestamps
    property :confirmed_at, type: :time
    property :created_at, type: :time
    property :locked_at, type: :time
    property :updated_at, type: :time
    property :last_sign_in_at, type: :time
    # Other
    property :admin_role, type: :string
    property :api_key, type: :string
    property :api_secret, type: :string
    property :avatar_url, type: :string
    property :company, type: :string
    property :email, type: :string
    property :geo_country_code, type: :string
    property :geo_state_code, type: :string
    property :geo_city, type: :string
    property :geo_tz, type: :string
    property :last_sign_in_ip
    property :name, type: :string
    property :password, type: :string
    property :current_password, type: :string
    property :password_confirmation, type: :string
    property :phone, type: :string
    property :phone_country_code, type: :string
    property :confirmation_token, type: :string
    property :unconfirmed_email
    property :settings
    property :sso_session, type: :string
    property :surname, type: :string
    property :website, type: :string
    property :geo_currency, type: :string
    property :failed_attempts
    property :password_changed_at
    # Two factor
    property :otp_attempt_successful, type: :boolean
    property :unconfirmed_otp_secret, type: :string

    has_one :sub_tenant

    define_model_callbacks :validation #required by Devise
    define_model_callbacks :update #required by Devise
    define_model_callbacks :create #required by Devise
    define_model_callbacks :save #required by Devise

    def self.validates_uniqueness_of(*attr_names)
      validates_with JsonApiClientExtension::Validations::RemoteUniquenessValidator, _merge_attributes(attr_names)
    end

    # Configure devise in a method so it can be done one the settings have loaded
    def self.configure_devise
      devise_modules = [
        :remote_authenticatable, :recoverable, :rememberable,
        :trackable, :validatable, :lockable, :confirmable, :timeoutable, :password_expirable,
        :omniauthable
      ]
      devise_modules << :registerable if Settings&.dashboard&.registration&.enabled
      devise(*devise_modules, omniauth_providers: Devise.omniauth_providers)
    end
    configure_devise

    #================================
    # Validation
    #================================

    if Devise.password_regex
      validates :password, format: { with: Devise.password_regex, message: Devise.password_regex_message }, if: :password_required?
    end

    def initialize(params = {})
      attributes
      super
    end

    custom_endpoint :create_api_credentials, on: :member, request_method: :patch
    custom_endpoint :authenticate, on: :collection, request_method: :post
    custom_endpoint :update_password, on: :member, request_method: :patch
    custom_endpoint :update_clients, on: :member, request_method: :patch

    #================================
    # Class Methods
    #================================
    # The auth_hash includes an email and password
    # Return nil in case of failure
    def self.authenticate_user(auth_hash)
      result = self.authenticate({ data: { attributes: auth_hash } })
      if (u = result&.first) && u.id
        u
      end
    rescue JsonApiClient::Errors::NotFound

    end

    def authenticatable_salt
      read_attribute(:authenticatable_salt)
    end

    def expire_user_cache
      Rails.cache.delete(['user', self.to_key])
      true # Don't skip save if above return false (memory_store)
    end

    def refresh_user_cache
      self.expire_view_cache
      reloaded = self.load_required_dependencies
      Rails.cache.write(['user', reloaded.to_key], reloaded)
    end

    def load_required_dependencies
      load_required(*INCLUDED_DEPENDENCIES)
    end

    def role(organization)
      self.role_from_id(organization.id)
    end

    def orga_relation(organization)
      self.orga_relation_from_id(organization.id)
    end

    def role_from_id(organization_id)
      relation = self.orga_relation_from_id(organization_id)
      return relation.role if relation
    end

    def orga_relation_from_id(organization_id)
      self.orga_relations.find { |r| r.organization_id == organization_id }
    end

    def create_deletion_request!
      MnoEnterprise::DeletionRequest.create!(deletable_id: self.id, deletable_type: 'User')
    end

    def current_deletion_request
      @current_deletion_request ||= if self.account_frozen
                                      self.deletion_requests.sort_by(&:created_at).last
                                    else
                                      self.deletion_requests.select(&:active?).sort_by(&:created_at).first
                                    end
    end

    def update_password!(input)
      result = update_password(input)
      process_custom_result(result)
    end

    def create_api_credentials!
      result = create_api_credentials
      process_custom_result(result)
    end

    def update_clients!(input)
      result = update_clients(input)
      process_custom_result(result)
    end

    def clear_clients!
      result = update_clients({data: {attributes: {set: []}}})
      process_custom_result(result)
    end

    # Find a user using a confirmation token
    def self.find_for_confirmation(confirmation_token)
      original_token = confirmation_token
      confirmation_token = Devise.token_generator.digest(self, :confirmation_token, confirmation_token)

      confirmable = find_or_initialize_with_error_by(:confirmation_token, confirmation_token)
      confirmable = find_or_initialize_with_error_by(:confirmation_token, original_token) if confirmable.errors.any?
      confirmable
    end

    def perform_confirmation(confirmation_token)
      self.confirm if self.persisted?
      self.confirmation_token = confirmation_token
      self.last_sign_in_at = Time.now
    end

    # Used by omniauth providers to find or create users
    # on maestrano
    # See Auth::OmniauthCallbacksController
    def self.find_for_oauth(auth, opts = {}, signed_in_resource = nil)
      # Get the identity and user if they exist
      identity = Identity.find_for_oauth(auth)

      # If a signed_in_resource is provided it always overrides the existing user
      # to prevent the identity being locked with accidentally created accounts.
      # Note that this may leave zombie accounts (with no associated identity) which
      # can be cleaned up at a later date.
      user = signed_in_resource ? signed_in_resource : (User.find_one(identity.user_id) if identity && identity.user_id)

      # Create the user if needed
      unless user # WTF is wrong with user.nil?
        # Get the existing user by email.
        email = auth.info.email
        user = self.where(email: email).first if email

        # Create the user if it's a new registration
        if user.nil?
          user = create_from_omniauth(auth, opts.except(:authorized_link_to_email))
        elsif auth.provider == 'intuit'
          unless opts[:authorized_link_to_email] == user.email
            # Intuit email is NOT a confirmed email. Therefore we need to ask the user to
            # login the old fashion to make sure it is the right user!
            fail(SecurityError, 'reconfirm credentials')
          end
        end
      end

      # Associate the identity with the user if needed
      if identity.user_id != user.id
        identity.user_id = user.id
        identity.save
      end
      user
    end

    # Create a new user from omniauth hash
    def self.create_from_omniauth(auth, opts = {})
      user = User.new(
        name: auth.info.first_name.presence || auth.info.email[/(\S*)@/, 1],
        surname: auth.info.last_name.presence || '',
        email: auth.info.email,
        password: Devise.friendly_token[0, 20],
        avatar_url: auth.info.image.presence
      )

      # opts hash is expected to contain additional attributes
      # to set on the model
      user.attributes = opts

      # Skip email confirmation if not from Intuit (Intuit email is NOT a confirmed email)
      user.skip_confirmation! unless auth.provider == 'intuit'
      user.save

      user
    end

    def to_audit_event
      {
        user_name: to_s,
        user_email: email
      }
    end

    def password_required?
      !persisted? || !password.nil? || !password_confirmation.nil?
    end

    def access_request_status(user)
      if user_access_requests
        request = user_access_requests.select { |r| !r.requester_id  || r.requester_id == user.id}.sort_by(&:created_at).last
        return request.current_status if request
      end
      'never_requested'
    end

    def support?
      admin_role.to_s.casecmp(SUPPORT_ROLE).zero?
    end

    def staff?
      admin_role.to_s.casecmp(STAFF_ROLE).zero?
    end

    def admin?
      admin_role.to_s.casecmp(ADMIN_ROLE).zero?
    end

    def requires_otp_for_login?
      if admin?
        Settings&.authentication&.two_factor&.admin_enabled
      else
        Settings&.authentication&.two_factor&.users_enabled
      end
    end

    def activate_otp
      self.attributes = {
        otp_required_for_login: true,
        unconfirmed_otp_secret: nil
      }
      save!
      reload
    end

    def set_quick_response_code_in_attributes
      two_factor_url = 'otpauth://totp/'\
                       "#{Settings.authentication.two_factor.app_id}:"\
                       "#{email}?"\
                       "secret=#{unconfirmed_otp_secret}"\
                       "&issuer=#{Settings.authentication.two_factor.app_name}"
      qr_code = RQRCode::QRCode.new(two_factor_url)
                               .to_img
                               .resize(240, 240)
                               .to_data_url
      attributes['quick_response_code'] = qr_code
    end

    def validate_and_consume_otp!(otp_attempt)
      self.attributes = {
        otp_attempt: otp_attempt,
        otp_attempt_successful: false
      }
      save!
      reload.otp_attempt_successful
    end
  end
end
