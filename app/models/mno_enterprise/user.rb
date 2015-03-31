# == Schema Information
#
# Endpoint: 
#   - /v1/users
#   - /v1/organizations/:organization_id/users
#
#  id                             :string          e.g.: usr-1d4f56
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
#

module MnoEnterprise
  class User < BaseResource
    extend Devise::Models
    
    # Note: password and encrypted_password are write-only attributes and are never returned by
    # the remote API. If you are looking for a session token, use authenticatable_salt
    attributes :email, :password, :authenticatable_salt, :encrypted_password, :reset_password_token, :reset_password_sent_at, 
      :remember_created_at, :sign_in_count, :current_sign_in_at, :last_sign_in_at, :current_sign_in_ip, 
      :last_sign_in_ip, :confirmation_token, :confirmed_at, :confirmation_sent_at, :unconfirmed_email, 
      :failed_attempts, :unlock_token, :locked_at, :name, :surname, :company, :phone, :phone_country_code, 
      :geo_country_code, :geo_state_code, :geo_city
    
    define_model_callbacks :validation #required by Devise
    devise :remote_authenticatable, :registerable, :recoverable, :rememberable,
      :trackable, :validatable, :lockable, :confirmable
    
    #================================
    # Associations
    #================================
    has_many :organizations, class_name: 'MnoEnterprise::Organization'
    has_one :deletion_request, class_name: 'MnoEnterprise::DeletionRequest'
    
    # The auth_hash includes an email and password
    # Return nil in case of failure
    def self.authenticate(auth_hash)
      u = self.post("user_sessions", auth_hash)
      
      if u && u.id
        puts "MnoEnterprise::User | authenticate | u.changes: #{u.changes}"
        u.clear_attribute_changes!
        return u
      end
      
      nil
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
  end
end
