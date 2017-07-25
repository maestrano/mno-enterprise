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
#  industry                 :string(255)
#  size                     :string(255)
#

module MnoEnterprise::Concerns::Models::Organization
  extend ActiveSupport::Concern

  #==================================================================
  # Included methods
  #==================================================================
  # 'included do' causes the included code to be evaluated in the
  # context where it is included rather than being executed in the module's context
  included do
    attributes :uid, :orga_relation_id, :name, :account_frozen, :free_trial_end_at, :soa_enabled, :mails, :logo,
      :latitude, :longitude, :geo_country_code, :geo_state_code, :geo_city, :geo_tz, :geo_currency,
      :meta_data, :industry, :size, :financial_year_end_month

    scope :in_arrears, -> { where(in_arrears?: true) }

    scope :active, -> { where(account_frozen: false) }

    default_scope lambda { where(account_frozen: false) }

    #================================
    # Associations
    #================================
    has_many :users, class_name: 'MnoEnterprise::User'
    has_many :org_invites, class_name: 'MnoEnterprise::OrgInvite'
    has_many :app_instances, class_name: 'MnoEnterprise::AppInstance'
    has_many :invoices, class_name: 'MnoEnterprise::Invoice'
    has_one  :credit_card, class_name: 'MnoEnterprise::CreditCard'
    has_many :teams, class_name: 'MnoEnterprise::Team'
    has_many :dashboards, class_name: 'MnoEnterprise::Impac::Dashboard'
    has_many :widgets, class_name: 'MnoEnterprise::Impac::Widget'
    has_one :raw_last_invoice, class_name: 'MnoEnterprise::Invoice', path: '/last_invoice'
    has_one :app_instances_sync, class_name: 'MnoEnterprise::AppInstancesSync'
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
  #
  # @params [Boolean] show_staged Also displayed staged invites (ie: not sent)
  def members(show_staged=false)
    invites = show_staged ? self.org_invites.active_or_staged : self.org_invites.active
    [self.users, invites.to_a].flatten
  end

  # Add a user to the organization with the provided role
  # TODO: specs
  def add_user(user,role = 'Member')
    self.users.create(id: user.id, role: role)
  end

  def last_invoice
    inv = self.raw_last_invoice
    inv.id ? inv : nil
  end
  # def last_invoice_with_nil
  #   last_invoice.respond_to?(:id) ? last_invoice : nil
  # end
  # alias_method_chain :last_invoice, :nil

  # Remove a user from the organization
  # TODO: specs
  def remove_user(user)
    self.users.destroy(id: user.id)
  end

  # Change a user role in the organization
  # TODO: specs
  def update_user(user, role = 'Member')
    self.users.update(id: user.id, role: role)
  end

  def to_audit_event
    {
      id: id,
      uid: uid,
      name: name
    }
  end

  def payment_restriction
    meta_data && meta_data['payment_restriction']
  end

  def has_credit_card_details?
    credit_card.persisted?
  end
end
