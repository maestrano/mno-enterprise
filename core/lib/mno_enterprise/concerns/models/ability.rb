module MnoEnterprise::Concerns::Models::Ability
  extend ActiveSupport::Concern

  #==================================================================
  # Included methods
  #==================================================================
  included do
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
  def initialize(user)
    user ||= MnoEnterprise::User.new(id: nil)

    #===================================================
    # Organization
    #===================================================
    can :create, MnoEnterprise::OrgaRelation

    can :read, MnoEnterprise::OrgaRelation do |orga_relation|
      !!orga_relation
    end

    can [:update, :destroy, :manage_billing], MnoEnterprise::OrgaRelation do |orga_relation|
      orga_relation&.role == 'Super Admin'
    end

    # TODO: replace by organization_id, no need to load a full organization, and make user.role accept a string
    can [:upload,
         :purchase,
         :invite_member,
         :administrate,
         :manage_app_instances,
         :manage_teams], MnoEnterprise::OrgaRelation do |orga_relation|
      orga_relation && ['Super Admin', 'Admin'].include?(orga_relation.role)
    end

    # To be updated
    # TODO: replace by organization_id, no need to load a full organization
    can :sync_apps, MnoEnterprise::OrgaRelation do |orga_relation|
      !!orga_relation
    end

    # To be updated
    # TODO: replace by organization_id, no need to load a full organization
    can :check_apps_sync, MnoEnterprise::OrgaRelation do |orga_relation|
      !!orga_relation
    end

    #===================================================
    # AppInstance
    #===================================================
    can :access, MnoEnterprise::AppInstance do |app_instance|
      orga_relation = MnoEnterprise::OrgaRelation.where('user.id': user.id, 'organization.id': app_instance.owner_id).first
      role = orga_relation&.role
      if role && ['Super Admin', 'Admin'].include?(role)
        true
      else
        teams = MnoEnterprise::Team.where('users.id': user.id).includes(:app_instances).with_params(fields: { app_instances: 'id' })
        teams.empty? || teams.map(&:app_instances).compact.flatten.map(&:id).include?(app_instance.id)
      end
    end

    #===================================================
    # Impac
    #===================================================
    impac_abilities(user)

    #===================================================
    # Admin abilities
    #===================================================
    admin_abilities(user)

    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
  end

  def impac_abilities(user)
    can :manage_impac, MnoEnterprise::Dashboard do |dhb|
      dhb.organizations.any? && dhb.organizations.all? do |org|
        role = orga_relation(user.id, org.id)&.role
        role && ['Super Admin', 'Admin'].include?(role)
      end
    end

    can :manage_dashboard, MnoEnterprise::Dashboard do |dashboard|
      if dashboard.owner_type == 'Organization'
        # The current user is a member of the organization that owns the dashboard that has the kpi attached to
        !!orga_relation(user, dashboard.owner_id)
      elsif dashboard.owner_type == "User"
        # The current user is the owner of the dashboard that has the kpi attached to
        dashboard.owner_id == user.id
      else
        false
      end
    end

    can :manage_widget, MnoEnterprise::Widget do |widget|
      dashboard = widget.dashboard
      authorize! :manage_dashboard, dashboard
    end

    can :manage_kpi, MnoEnterprise::Kpi do |kpi|
      if kpi.widget.present?
        authorize! :manage_widget, MnoEnterprise::Widget.find(kpi.widget.id)
      else
        authorize! :manage_dashboard, kpi.dashboard
      end
    end

    can :manage_alert, MnoEnterprise::Alert do |alert|
      kpi = alert.kpi
      authorize! :manage_kpi, kpi
    end
  end

  # Abilities for admin user
  def admin_abilities(user)
    if user.admin_role.to_s.casecmp('admin').zero? || user.admin_role.to_s.casecmp('staff').zero?
      can :manage_app_instances, MnoEnterprise::OrgaRelation
      can :manage_sub_tenant, MnoEnterprise::SubTenant
    end
  end
end
