module MnoEnterprise
  class AppInstancesSync < BaseResource
    attributes :errors, :connectors, :mode
    belongs_to :organization, class_name: 'MnoEnterprise::Organization'
  end
end
