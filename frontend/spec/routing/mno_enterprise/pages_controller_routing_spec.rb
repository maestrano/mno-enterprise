require "rails_helper"

module MnoEnterprise
  RSpec.describe PagesController, type: :routing do
    routes { MnoEnterprise::Engine.routes }

    describe "myspace" do
      it "routes to myspace" do
        expect(get("/myspace")).to route_to("mno_enterprise/pages#myspace")
      end

      it "routes to myspace_billing" do
        expect(get("/myspace#/billing")).to route_to("mno_enterprise/pages#myspace")
      end
    end

  end
end
