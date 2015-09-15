require "rails_helper"

module MnoEnterprise
  RSpec.describe DeletionRequestsController, type: :routing do
    routes { MnoEnterprise::Engine.routes }

    it "routes to #show" do
      expect(get("/deletion_requests/1")).to route_to("mno_enterprise/deletion_requests#show", id: '1')
    end

    it "routes to #freeze_account" do
      expect(patch("/deletion_requests/1/freeze_account")).to route_to("mno_enterprise/deletion_requests#freeze_account", id: '1')
    end

    it 'routes to #checkout' do
      expect(patch("/deletion_requests/1/checkout")).to route_to("mno_enterprise/deletion_requests#checkout", id: '1')
    end
    it 'routes to #terminate_account'
  end
end
