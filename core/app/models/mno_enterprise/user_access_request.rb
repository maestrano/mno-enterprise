module MnoEnterprise
  class UserAccessRequest < BaseResource

    has_one :user
    has_one :requester

  end
end
