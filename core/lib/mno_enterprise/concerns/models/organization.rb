module MnoEnterprise::Concerns::Models::Organization
  extend ActiveSupport::Concern

  #==================================================================
  # Included methods
  #==================================================================
  # 'included do' causes the included code to be evaluated in the
  # context where it is included rather than being executed in the module's context
  included do
    attributes :uid, :name, :account_frozen, :free_trial_end_at, :soa_enabled, :mails, :logo,
      :latitude, :longitude, :geo_country_code, :geo_state_code, :geo_city, :geo_tz, :geo_currency,
      :meta_data, :industry, :size

    #================================
    # Associations
    #================================
    has_many :users, class_name: 'MnoEnterprise::User'
    has_many :org_invites, class_name: 'MnoEnterprise::OrgInvite'
    has_many :app_instances, class_name: 'MnoEnterprise::AppInstance'
    has_many :invoices, class_name: 'MnoEnterprise::Invoice'
    has_one :credit_card, class_name: 'MnoEnterprise::CreditCard'
    has_many :teams, class_name: 'MnoEnterprise::Team'
    has_many :dashboards, class_name: 'MnoEnterprise::Impac::Dashboard'
  end

  #==================================================================
  # Class methods
  #==================================================================
  module ClassMethods
    # def some_class_method
    #   'some text'
    # end
  end

  #==================================================================
  # Instance methods
  #==================================================================
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
