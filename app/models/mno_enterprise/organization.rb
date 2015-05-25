# == Schema Information
#
# Endpoint: 
#  - /v1/organizations
#  - /v1/users/:user_id/organizations
#
#  id                       :integer         not null, primary key
#  uid                      :string(255)
#  name                     :string(255)
#  created_at               :datetime        not null
#  updated_at               :datetime        not null
#  account_frozen           :boolean         default(FALSE)
#  free_trial_end_at        :datetime
#  soa_enabled              :boolean         default(TRUE)
#  mails                    :text
#  logo                     :string(255)
#  latitude                 :float           default(0.0)
#  longitude                :float           default(0.0)
#  geo_country_code         :string(255)
#  geo_state_code           :string(255)
#  geo_city                 :string(255)
#  geo_tz                   :string(255)
#  geo_currency             :string(255)
#  meta_data                :text
#

module MnoEnterprise
  class Organization < BaseResource    
    attributes :uid, :name, :account_frozen, :free_trial_end_at, :soa_enabled, :mails, :logo,
      :latitude, :longitude, :geo_country_code, :geo_state_code, :geo_city, :geo_tz, :geo_currency,
      :meta_data
    
    #================================
    # Associations
    #================================
    has_many :users, class_name: 'MnoEnterprise::User'
    has_many :org_invites, class_name: 'MnoEnterprise::OrgInvite'
    has_many :app_instances, class_name: 'MnoEnterprise::AppInstance'
    has_many :invoices, class_name: 'MnoEnterprise::Invoice'
    has_one :credit_card, class_name: 'MnoEnterprise::CreditCard'
    
    # Return the list of users + active invites
    # TODO: specs
    def members
      [self.users,self.org_invites.active].flatten
    end
    
    # Add a user to the organization with the provided role
    # TODO: specs
    def add_user(user,role = 'Member')
      self.users.create(id: user.id, role: role)
    end
    
    # Remove a user from the organization
    # TODO: specs
    def remove_user(user)
      self.users.destroy(id: user.id)
    end
  end
end
