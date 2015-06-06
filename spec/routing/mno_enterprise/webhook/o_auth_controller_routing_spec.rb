require "rails_helper"

module MnoEnterprise
  RSpec.describe Webhook::OAuthController, type: :routing do
    routes { MnoEnterprise::Engine.routes }
    
    it "routes to #authorize" do
      expect(get("/webhook/oauth/cld-1f47d5s4/authorize")).to route_to("mno_enterprise/webhook/o_auth#authorize", id: 'cld-1f47d5s4')
      expect(get("/webhook/oauth/bla.mcube.co/authorize")).to route_to("mno_enterprise/webhook/o_auth#authorize", id: 'bla.mcube.co')
    end
    
    it "routes to #callback" do
      expect(get("/webhook/oauth/cld-1f47d5s4/callback")).to route_to("mno_enterprise/webhook/o_auth#callback", id: 'cld-1f47d5s4')
      expect(get("/webhook/oauth/bla.mcube.co/callback")).to route_to("mno_enterprise/webhook/o_auth#callback", id: 'bla.mcube.co')
    end
    
    it "routes to #disconnect" do
      expect(get("/webhook/oauth/cld-1f47d5s4/disconnect")).to route_to("mno_enterprise/webhook/o_auth#disconnect", id: 'cld-1f47d5s4')
      expect(get("/webhook/oauth/bla.mcube.co/disconnect")).to route_to("mno_enterprise/webhook/o_auth#disconnect", id: 'bla.mcube.co')
    end
    
    it "routes to #sync" do
      expect(get("/webhook/oauth/cld-1f47d5s4/sync")).to route_to("mno_enterprise/webhook/o_auth#sync", id: 'cld-1f47d5s4')
      expect(get("/webhook/oauth/bla.mcube.co/sync")).to route_to("mno_enterprise/webhook/o_auth#sync", id: 'bla.mcube.co')
    end
  end
end