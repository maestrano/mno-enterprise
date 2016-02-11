module MnoEnterprise
  class AppInstancesSync < BaseResource
    attributes :connectors, :mode
    belongs_to :organization, class_name: 'MnoEnterprise::Organization'
  end
end
