module MnoEnterprise
  class OrganizationAppInstancesSync < BaseResource
    attributes :connectors, :mode
    belongs_to :organization, class_name: 'MnoEnterprise::Organization'
  end
end
