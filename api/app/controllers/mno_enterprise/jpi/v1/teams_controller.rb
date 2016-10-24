# This controller uses nesting (under organizations) and shallow routes
module MnoEnterprise
  class Jpi::V1::TeamsController < Jpi::V1::BaseResourceController
    include MnoEnterprise::Concerns::Controllers::Jpi::V1::TeamsController
  end
end
