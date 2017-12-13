module MnoEnterprise::Concerns::Models::Organization
  extend ActiveSupport::Concern

  #==================================================================
  # Included methods
  #==================================================================
  # 'included do' causes the included code to be evaluated in the
  # context where it is included rather than being executed in the module's context
  included do
    custom_endpoint :app_instances_sync, on: :member, request_method: :get
    custom_endpoint :trigger_app_instances_sync, on: :member, request_method: :post
    custom_endpoint :freeze, on: :member, request_method: :patch
    custom_endpoint :unfreeze, on: :member, request_method: :patch

    property :uid, type: :string
    property :name, type: :string
    property :account_frozen, type: :boolean
    property :free_trial_end_at, type: :string
    property :soa_enabled, type: :boolean
    property :mails, type: :string
    property :logo, type: :string

    property :latitude, type: :float
    property :longitude, type: :float
    property :geo_country_code, type: :string
    property :geo_state_code, type: :string
    property :geo_city, type: :string
    property :geo_tz, type: :string
    property :geo_currency, type: :string
    property :metadata
    property :industry, type: :string
    property :size, type: :int
    property :financial_year_end_month, type: :string
    property :credit_card_id
    property :financial_metrics
    property :billing_currency
    property :external_id, type: :string
    property :belong_to_sub_tenant, type: :boolean
    property :belong_to_account_manager, type: :boolean
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
    invites = self.orga_invites.select do |invite|
      if show_staged
        %w(pending staged).include? invite.status
      else
        invite.status == 'staged'
      end
    end
    [self.users, invites.to_a].flatten
  end

  def active?
    !self.account_frozen
  end

  def payment_restriction
    metadata && metadata['payment_restriction']
  end

  def role(user)
    relation = self.orga_relation(user)
    return relation.role if relation
  end

  def orga_relation(user)
    self.orga_relations.find { |r|
      r.user_id == user.id
    }
  end

  # Update a user role within self
  #
  # @param user [MnoEnterprise::User] the user performing the action
  # @param updated_user [MnoEnterprise::User, MnoEnterprise::OrgaInvite] the user to update
  # @param new_role [String] the role to assign to updated_user
  #
  def update_user_role(user, updated_user, new_role)
    if user.role(self) == 'Admin'
      # Admin cannot assign Super Admin role
      raise CanCan::AccessDenied if new_role == 'Super Admin'
      current_role = if updated_user.is_a?(MnoEnterprise::User)
                          role(updated_user)
                        elsif updated_user.is_a?(MnoEnterprise::OrgaInvite)
                          updated_user.user_role
                        end
      # Admin cannot edit Super Admin
      if current_role == 'Super Admin'
        raise CanCan::AccessDenied
      end
    elsif updated_user.id == user.id && new_role != 'Super Admin' && orga_relations.count { |u| u.role == 'Super Admin' } <= 1
      # A super admin cannot modify his role if he's the last super admin
      raise CanCan::AccessDenied
    end

    # Happy Path
    case updated_user
    when MnoEnterprise::User
      orga_relation = orga_relations.find { |rel| rel.user_id == updated_user.id }
      orga_relation.update_attributes!(role: new_role)
    when MnoEnterprise::OrgaInvite
      updated_user.update_attributes!(user_role: new_role)
    end
  end

  def remove_user!(user)
    relation = self.orga_relation(user)
    relation.destroy! if relation
  end

  def add_user!(user, role = 'Member')
    MnoEnterprise::OrgaRelation.create!(organization_id: self.id, user_id: user.id, role: role)
  end

  def provision_app_instance!(app_nid)
    input = { data: { attributes: { app_nid: app_nid, owner_id: id, owner_type: 'Organization' } } }
    MnoEnterprise::AppInstance.provision!(input)
  end

  def new_credit_card
    MnoEnterprise::CreditCard.new(owner_id: id, owner_type: 'Organization')
  end

  def has_credit_card_details?
    credit_card_id.present?
  end

  def freeze!
    result = freeze
    self.attributes = process_custom_result(result).attributes
  end

  def unfreeze!
    result = unfreeze
    self.attributes = process_custom_result(result).attributes
  end

  def app_instances_sync!
    result = app_instances_sync
    process_custom_result(result)
  end

  def trigger_app_instances_sync!
    result = trigger_app_instances_sync
    process_custom_result(result)
  end

  def to_audit_event
    {
      id: id,
      uid: uid,
      name: name
    }
  end
end
