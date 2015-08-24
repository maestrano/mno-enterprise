require "rails_helper"

module MnoEnterprise
  RSpec.describe DeletionRequestsController, type: :routing do
    routes { MnoEnterprise::Engine.routes }

    it "routes to #show" do
      expect(get("/deletion_requests/1")).to route_to("mno_enterprise/deletion_requests#show", id: '1')
    end
  end
end
