# /v1/users
module MnoEnterprise
  class User < BaseResource
    include ActiveModel::Validations #required because some before_validations are defined in devise
    extend ActiveModel::Callbacks #required to define callbacks
    extend Devise::Models
    
    attr_accessor :email
    
    define_model_callbacks :validation #required by Devise
    devise :remote_authenticatable
    
    # The auth_hash includes an email and password
    # Return nil in case of failure
    def self.authenticate(auth_hash)
      u = self.post(:authenticate, auth_hash)
      u.id ? u : nil
    end
  end
end
