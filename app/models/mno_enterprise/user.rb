# == Schema Information
#
# Endpoint: 
#   - /v1/users
#   - /v1/organizations/:organization_id/users
#
#  id                             :string          e.g.: usr-1d4f56
#  email                          :string(255)     default(""), not null
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
#

module MnoEnterprise
  class User < BaseResource
    extend Devise::Models
    
    attributes :email, :password, :encrypted_password, :reset_password_token, :reset_password_sent_at, 
      :remember_created_at, :sign_in_count, :current_sign_in_at, :last_sign_in_at, :current_sign_in_ip, 
      :last_sign_in_ip, :confirmation_token, :confirmed_at, :confirmation_sent_at, :unconfirmed_email, 
      :failed_attempts, :unlock_token, :locked_at, :name,:surname
    
    define_model_callbacks :validation #required by Devise
    devise :remote_authenticatable, :registerable, :recoverable, :rememberable,
      :trackable, :validatable, :lockable, :confirmable
    
    #================================
    # Associations
    #================================
    has_many :organization, class_name: 'MnoEnterprise::Organization'
    
    # The auth_hash includes an email and password
    # Return nil in case of failure
    def self.authenticate(auth_hash)
      u = self.post(:authenticate, auth_hash)
      
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
  end
end
