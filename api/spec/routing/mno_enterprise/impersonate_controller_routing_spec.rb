require "rails_helper"

module MnoEnterprise
  RSpec.describe ImpersonateController, type: :routing do
    routes { MnoEnterprise::Engine.routes }

    it "routes to #create" do
      expect(get("/impersonate/user/1")).to route_to("mno_enterprise/impersonate#create", user_id: '1')
    end

    it "routes to #destroy" do
      expect(get("/impersonate/revert")).to route_to("mno_enterprise/impersonate#destroy")
    end
  end
end
