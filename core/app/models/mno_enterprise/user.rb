# == Schema Information
#
# Endpoint:
#   - /v1/users
#   - /v1/organizations/:organization_id/users
#
#  id                             :string          e.g.: 1
#  uid                            :string          e.g.: usr-k3j23npo
#  email                          :string(255)     default(""), not null
#  authenticatable_salt           :string(255)     used for session authentication
#  encrypted_password             :string(255)     default(""), not null
#  reset_password_token           :string(255)
#  reset_password_sent_at         :datetime
#  remember_created_at            :datetime
#  sign_in_count                  :integer         default(0)
#  current_sign_in_at             :datetime
#  last_sign_in_at                :datetime
#  current_sign_in_ip             :string(255)
#  last_sign_in_ip                :string(255)
#  confirmation_token             :string(255)
#  confirmed_at                   :datetime
#  confirmation_sent_at           :datetime
#  unconfirmed_email              :string(255)
#  failed_attempts                :integer         default(0)
#  unlock_token                   :string(255)
#  locked_at                      :datetime
#  created_at                     :datetime        not null
#  updated_at                     :datetime        not null
#  name                           :string(255)
#  surname                        :string(255)
#  company                        :string(255)
#  phone                          :string(255)
#  phone_country_code             :string(255)
#  geo_country_code               :string(255)
#  geo_state_code                 :string(255)
#  geo_city                       :string(255)
#  website                        :string(255)
#

module MnoEnterprise
  class User < BaseResource
    include MnoEnterprise::Concerns::Models::IntercomUser if MnoEnterprise.intercom_enabled?
    extend Devise::Models

    # Note: password and encrypted_password are write-only attributes and are never returned by
    # the remote API. If you are looking for a session token, use authenticatable_salt
    attributes :uid, :email, :password, :current_password, :password_confirmation, :authenticatable_salt, :encrypted_password, :reset_password_token, :reset_password_sent_at,
      :remember_created_at, :sign_in_count, :current_sign_in_at, :last_sign_in_at, :current_sign_in_ip,
      :last_sign_in_ip, :confirmation_token, :confirmed_at, :confirmation_sent_at, :unconfirmed_email,
      :failed_attempts, :unlock_token, :locked_at, :name, :surname, :company, :phone, :phone_country_code,
      :geo_country_code, :geo_state_code, :geo_city, :website, :orga_on_create, :sso_session, :current_password_required, :admin_role

    define_model_callbacks :validation #required by Devise
    devise :remote_authenticatable, :registerable, :recoverable, :rememberable,
      :trackable, :validatable, :lockable, :confirmable, :timeoutable, :password_expirable

    #================================
    # Validation
    #================================
    validates_uniqueness_of :email, allow_blank: true, if: :email_changed?

    if Devise.password_regex
      validates :password, format: { with: Devise.password_regex, message: Devise.password_regex_message }, if: :password_required?
    end

    #================================
    # Associations
    #================================
    has_many :organizations, class_name: 'MnoEnterprise::Organization'
    has_many :org_invites, class_name: 'MnoEnterprise::OrgInvite'
    has_one :deletion_request, class_name: 'MnoEnterprise::DeletionRequest'
    has_many :dashboards, class_name: 'MnoEnterprise::Impac::Dashboard'
    has_many :teams, class_name: 'MnoEnterprise::Team'

    #================================
    # Callbacks
    #================================
    before_save :expire_user_cache

    #================================
    # Class Methods
    #================================
    # The auth_hash includes an email and password
    # Return nil in case of failure
    def self.authenticate(auth_hash)
      u = self.post("user_sessions", auth_hash)

      if u && u.id
        u.clear_attribute_changes!
        return u
      end

      nil
    end

    #================================
    # Devise Confirmation
    # TODO: should go in a module
    #================================


    # Override Devise to allow confirmation via original token
    # Less secure but useful if user has been created by Maestrano Enterprise
    # (happens when an orga_invite is sent to a new user)
    #
    # Find a user by its confirmation token and try to confirm it.
    # If no user is found, returns a new user with an error.
    # If the user is already confirmed, create an error for the user
    # Options must have the confirmation_token
    def self.confirm_by_token(confirmation_token)
      confirmable = self.find_for_confirmation(confirmation_token)
      confirmable.perform_confirmation(confirmation_token)
      confirmable
    end

    # Find a user using a confirmation token
    def self.find_for_confirmation(confirmation_token)
      original_token     = confirmation_token
      confirmation_token = Devise.token_generator.digest(self, :confirmation_token, confirmation_token)

      confirmable = find_or_initialize_with_error_by(:confirmation_token, confirmation_token)
      confirmable = find_or_initialize_with_error_by(:confirmation_token, original_token) if confirmable.errors.any?
      confirmable
    end

    # Confirm the user and store confirmation_token
    def perform_confirmation(confirmation_token)
      self.confirm if self.persisted?
      self.confirmation_token = confirmation_token
    end

    # It may happen that that the errors attribute become nil, which breaks the controller logic (rails responder)
    # This getter ensures that 'errors' is always initialized
    def errors
      @errors ||= ActiveModel::Errors.new(self)
    end

    # Don't require a password for unconfirmed users (user save password at confirmation step)
    def password_required?
      super if confirmed?
    end

    #================================
    # Instance Methods
    #================================

    def to_s
      "#{name} #{surname}"
    end

    # Format for audit log
    def to_audit_event
      {
        user_name: to_s,
        user_email: email
      }
    end

    # Default value for failed attempts
    def failed_attempts
      read_attribute(:failed_attempts) || 0
    end

    # Override Devise default method
    def authenticatable_salt
      read_attribute(:authenticatable_salt)
    end

    # Return the role of this user for the provided
    # organization
    def role(organization = nil)
      # Return cached version if available
      return self.read_attribute(:role) if !organization

      org = self.organizations.to_a.find { |o| o.id.to_s == organization.id.to_s }
      org ? org.role : nil
    end

    def expire_user_cache
      Rails.cache.delete(['user', self.to_key])
      true # Don't skip save if above return false (memory_store)
    end

    def refresh_user_cache
      self.reload
      Rails.cache.write(['user', self.to_key], self)
    end
  end
end
