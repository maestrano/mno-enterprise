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
    # Impac
    #===================================================
    impac_abilities(user)

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
    can :manage_impac, MnoEnterprise::Impac::Dashboard do |dhb|
      dhb.organizations.any? && dhb.organizations.all? do |org|
        !!user.role(org) && ['Super Admin', 'Admin'].include?(user.role(org))
      end
    end
  end
end
