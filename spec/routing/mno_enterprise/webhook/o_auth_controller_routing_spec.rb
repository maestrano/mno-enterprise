require "rails_helper"

module MnoEnterprise
  RSpec.describe Webhook::OAuthController, type: :routing do
    routes { MnoEnterprise::Engine.routes }
    
    it "routes to #authorize" do
      expect(get("/webhook/oauth/cld-1f47d5s4/authorize")).to route_to("mno_enterprise/webhook/o_auth#authorize", id: 'cld-1f47d5s4')
      expect(get("/webhook/oauth/bla.mcube.co/authorize")).to route_to("mno_enterprise/webhook/o_auth#authorize", id: 'bla.mcube.co')
    end
  end
end