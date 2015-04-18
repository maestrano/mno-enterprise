require "rails_helper"

module MnoEnterprise
  RSpec.describe OrgInvitesController, type: :routing do
    routes { MnoEnterprise::Engine.routes }
    
    it "routes to #show" do
      expect(get("/org_invites/1")).to route_to("mno_enterprise/org_invites#show", id: '1')
    end
        
  end
end