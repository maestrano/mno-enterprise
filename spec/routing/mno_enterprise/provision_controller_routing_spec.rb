require "rails_helper"

module MnoEnterprise
  RSpec.describe ProvisionController, type: :routing do
    routes { MnoEnterprise::Engine.routes }
    
    it "routes to #new" do
      expect(get("/provision/new")).to route_to("mno_enterprise/provision#new")
    end
    
    it 'routes to #create' do
      expect(post("/provision")).to route_to("mno_enterprise/provision#create")
    end
  end
end