require 'rails_helper'

module MnoEnterprise
  RSpec.describe Jpi::V1::AppInstancesSyncController, type: :routing do
    routes { MnoEnterprise::Engine.routes }
    
    it "routes to #index" do
      expect(get("/jpi/v1/organizations/org-fbba/app_instances_sync")).to route_to("mno_enterprise/jpi/v1/app_instances_sync#index",organization_id: 'org-fbba')
    end

    it "routes to #create" do
      expect(post("/jpi/v1/organizations/org-fbba/app_instances_sync")).to route_to("mno_enterprise/jpi/v1/app_instances_sync#create",organization_id: 'org-fbba')
    end
  end
end
