require "rails_helper"

module MnoEnterprise
  RSpec.describe UserSetupController, type: :routing do
    routes { MnoEnterprise::Engine.routes }
    
    it "routes to #index" do
      expect(get("/user_setup")).to route_to("mno_enterprise/user_setup#index")
    end
  end
end