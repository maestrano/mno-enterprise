module MnoEnterprise
  class  TenantInvoice < BaseResource
    #==============================================================
    # Associations
    #==============================================================
    belongs_to :organization, class_name: 'MnoEnterprise::Organization'

  end
end