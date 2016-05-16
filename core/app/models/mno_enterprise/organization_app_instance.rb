# == Schema Information
#
# Endpoint: 
#  - /v1/organization_app_instances
#  - /v1/organizations/:organization_id/organization_app_instances
#
#  id                   :integer         not null, primary key
#  uid                  :string(255)
#  name                 :string(255)
#  status               :string(255)
#  app_id               :integer
#  created_at           :datetime        not null
#  updated_at           :datetime        not null
#  started_at           :datetime
#  stack                :string(255)
#  owner_id             :integer
#  owner_type           :string(255)
#  terminated_at        :datetime
#  stopped_at           :datetime
#  billing_type         :string(255)
#  autostop_at          :datetime
#  autostop_interval    :integer
#  next_status          :string(255)
#  soa_enabled          :boolean         default(FALSE)


module MnoEnterprise
  class OrganizationAppInstance < BaseResource
    include MnoEnterprise::Concerns::Models::OrganizationAppInstance
  end
end
