module Mno
  class User < BaseResource
    # include MnoEnterprise::Concerns::Models::IntercomUser if MnoEnterprise.intercom_enabled?
    extend Devise::Models
    # include ActiveModel::Model
    include ActiveModel::Conversion
    include ActiveModel::AttributeMethods
    # extend ActiveModel::Callbacks
    include ActiveModel::Validations


    property :created_at, type: :time
    property :updated_at, type: :time
    property :email, type: :string
    property :name, type: :string

    define_model_callbacks :validation #required by Devise
    define_model_callbacks :update #required by Devise
    define_model_callbacks :create #required by Devise
    define_model_callbacks :save #required by Devise
    #:validatable, :confirmable
    devise :remote_authenticatable, :registerable, :recoverable, :rememberable,
           :trackable, :lockable, :timeoutable, :password_expirable,
           :omniauthable, omniauth_providers: Devise.omniauth_providers
    def initialize(params = {})
     attributes
      super
    end

    def validates_uniqueness_of

    end

    #================================
    # Validation
    #================================
    #
    # if Devise.password_regex
    #   validates :password, format: { with: Devise.password_regex, message: Devise.password_regex_message }, if: :password_required?
    # end
    #
    # before_save :expire_user_cache

    custom_endpoint :authenticate, on: :collection, request_method: :post

    #================================
    # Class Methods
    #================================
    # The auth_hash includes an email and password
    # Return nil in case of failure
    def self.authenticate_user(auth_hash)
      result = self.authenticate({data: {attributes: auth_hash}})
      if result
        u = result.first
        if u && u.id
          # u.clear_attribute_changes!
          return u
        end
      end
      nil
    end

    def authenticatable_salt
      read_attribute(:authenticatable_salt)
    end

    def deletion_request
      return self.deletion_requests.first if self.deletion_requests
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
