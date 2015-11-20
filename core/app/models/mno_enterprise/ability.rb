module MnoEnterprise
  class Ability
    include CanCan::Ability
    include MnoEnterprise::Concerns::Models::Ability
  end
end
