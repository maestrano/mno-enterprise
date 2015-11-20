module MnoEnterprise
  class ArrearsSituation < BaseResource
    belongs_to :organization, class_name: 'MnoEnterprise::Organization'
    attributes :payment
  end
end
