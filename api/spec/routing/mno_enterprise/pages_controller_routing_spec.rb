require "rails_helper"

module MnoEnterprise
  RSpec.describe PagesController, type: :routing do
    routes { MnoEnterprise::Engine.routes }

    it "routes to #launch" do
      expect(get("/launch/cld-1f47d5s4")).to route_to("mno_enterprise/pages#launch", id: 'cld-1f47d5s4')
      expect(get("/launch/bla.mcube.co")).to route_to("mno_enterprise/pages#launch", id: 'bla.mcube.co')
    end

    it "routes to #launch" do
      expect(get("/loading/cld-1f47d5s4")).to route_to("mno_enterprise/pages#loading", id: 'cld-1f47d5s4')
      expect(get("/loading/bla.mcube.co")).to route_to("mno_enterprise/pages#loading", id: 'bla.mcube.co')
    end

    it 'routes to #app_access_unauthorized' do
      expect(get("/app_access_unauthorized")).to route_to("mno_enterprise/pages#app_access_unauthorized")
    end

    it 'routes to #billing_details_required' do
      expect(get("/billing_details_required")).to route_to("mno_enterprise/pages#billing_details_required")
    end

    it 'routes to #app_logout' do
      expect(get("/app_logout")).to route_to("mno_enterprise/pages#app_logout")
    end

    it 'routes to #terms' do
      expect(get("/terms")).to route_to("mno_enterprise/pages#terms")
    end

    it 'routes to #error' do
      expect(get("/errors/503")).to route_to("mno_enterprise/pages#error", error_code: '503')
    end
  end
end
