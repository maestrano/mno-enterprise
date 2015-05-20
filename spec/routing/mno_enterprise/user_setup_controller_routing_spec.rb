require "rails_helper"

module MnoEnterprise
  RSpec.describe UserSetupController, type: :routing do
    routes { MnoEnterprise::Engine.routes }
    
    it "routes to #show" do
      expect(get("/user_setup/1")).to route_to("mno_enterprise/user_setup#show", id: '1')
    end
  end
end