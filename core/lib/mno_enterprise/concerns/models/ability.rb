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
  def initialize(user, session)
    user ||= MnoEnterprise::User.new

    #===================================================
    # Organization
    #===================================================
    can :create, MnoEnterprise::Organization

    can :read, MnoEnterprise::Organization do |organization|
      !!user.role(organization)
    end

    can [:update, :destroy, :manage_billing], MnoEnterprise::Organization do |organization|
      user.role(organization) == 'Super Admin'
    end

    can [:upload,
         :purchase,
         :invite_member,
         :administrate,
         :manage_app_instances,
         :manage_teams], MnoEnterprise::Organization do |organization|
      ['Super Admin','Admin'].include? user.role(organization)
    end

    # To be updated
    can :sync_apps, MnoEnterprise::Organization do |organization|
      user.role(organization)
    end

    # To be updated
    can :check_apps_sync, MnoEnterprise::Organization do |organization|
      user.role(organization)
    end

    #===================================================
    # AppInstance
    #===================================================
    can :access, MnoEnterprise::AppInstance do |app_instance|
      !!user.role(app_instance.owner) && (
      ['Super Admin','Admin'].include?(user.role(app_instance.owner)) ||
          user.teams.empty? ||
          user.teams.map(&:app_instances).compact.flatten.map(&:id).include?(app_instance.id)
      )
    end

    #===================================================
    # Admin abilities
    #===================================================
    admin_abilities(user)

    #===================================================
    # Impac
    #===================================================
    orgs_with_acl = user.organizations.active.include_acl(session[:impersonator_user_id]).to_a
    impac_abilities(orgs_with_acl)
  end

  # Abilities for admin user
  def admin_abilities(user)
    if user.admin_role.to_s.casecmp('admin').zero? || user.admin_role.to_s.casecmp('staff').zero?
      can :manage_app_instances, MnoEnterprise::Organization
    end
  end

  # Enables / disables Impac! Angular capabilities
  def impac_abilities(orgs_with_acl)
    can :create_impac_dashboards, MnoEnterprise::Impac::Dashboard do |d|
      orgs = d.organizations(orgs_with_acl)
      orgs.present? && orgs.all? { |org| org.acl.dig(:related, :dashboards, :create) }
    end

    can :update_impac_dashboards, MnoEnterprise::Impac::Dashboard do |d|
      orgs = d.organizations(orgs_with_acl)
      orgs.present? && orgs.all? { |org| org.acl.dig(:related, :dashboards, :update) }
    end

    can :destroy_impac_dashboards, MnoEnterprise::Impac::Dashboard do |d|
      orgs = d.organizations(orgs_with_acl)
      orgs.present? && orgs.all? { |org| org.acl.dig(:related, :dashboards, :destroy) }
    end

    can :create_impac_widgets, MnoEnterprise::Impac::Widget do |w|
      orgs = w.organizations(orgs_with_acl)
      orgs.present? && orgs.all? { |org| org.acl.dig(:related, :widgets, :create) }
    end

    can :update_impac_widgets, MnoEnterprise::Impac::Widget do |w|
      orgs = w.organizations(orgs_with_acl)
      orgs.present? && orgs.all? { |org| org.acl.dig(:related, :widgets, :update) }
    end

    can :destroy_impac_widgets, MnoEnterprise::Impac::Widget do |w|
      orgs = w.organizations(orgs_with_acl)
      orgs.present? && orgs.all? { |org| org.acl.dig(:related, :widgets, :destroy) }
    end

    can :create_impac_kpis, MnoEnterprise::Impac::Kpi do |k|
      orgs = k.organizations(orgs_with_acl)
      orgs.present? && orgs.all? { |org| org.acl.dig(:related, :kpis, :create) }
    end

    can :update_impac_kpis, MnoEnterprise::Impac::Kpi do |k|
      orgs = k.organizations(orgs_with_acl)
      orgs.present? && orgs.all? { |org| org.acl.dig(:related, :kpis, :update) }
    end

    can :destroy_impac_kpis, MnoEnterprise::Impac::Kpi do |k|
      orgs = k.organizations(orgs_with_acl)
      orgs.present? && orgs.all? { |org| org.acl.dig(:related, :kpis, :destroy) }
    end
  end
end
