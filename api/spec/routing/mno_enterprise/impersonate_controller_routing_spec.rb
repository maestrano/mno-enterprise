require "rails_helper"

module MnoEnterprise
  RSpec.describe ImpersonateController, type: :routing do
    routes { MnoEnterprise::Engine.routes }

    context "Impersonation is enabled" do
      before(:all) do
        Settings.merge!(admin_panel: {impersonation: {disabled: false}})
        Rails.application.reload_routes!
      end

      it "routes to #create" do
        expect(get("/impersonate/user/1")).to route_to("mno_enterprise/impersonate#create", user_id: '1')
      end

      it "routes to #destroy" do
        expect(get("/impersonate/revert")).to route_to("mno_enterprise/impersonate#destroy")
      end
    end

    context "Impersonation is disabled" do
      before(:all) do
        Settings.merge!(admin_panel: {impersonation: {disabled: true}})
        Rails.application.reload_routes!
      end

      it 'loads regular routes' do
        expect(get('/ping')).to route_to('mno_enterprise/status#ping')
      end

      it "does not route to #create" do
        expect(get("/impersonate/user/1")).not_to be_routable
      end

      it "does not route to #destroy" do
        expect(get("/impersonate/revert")).not_to be_routable
      end
    end
  end
end
