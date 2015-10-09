require 'rails_helper'

module MnoEnterprise
  RSpec.describe Jpi::V1::Impac::KpisController, type: :routing do
    routes { MnoEnterprise::Engine.routes }
   
    describe 'collection routes (dashboard nested)' do
      it "routes to #update" do
        put("/jpi/v1/impac/kpis/2").should route_to("mno_enterprise/jpi/v1/impac/kpis#update", id: '2')
      end

      it "routes to #destroy" do
        delete("/jpi/v1/impac/kpis/2").should route_to("mno_enterprise/jpi/v1/impac/kpis#destroy", id: '2')
      end

      it "routes to #create" do
        post("/jpi/v1/impac/dashboards/1/kpis").should route_to("mno_enterprise/jpi/v1/impac/kpis#create", dashboard_id: '1')
      end
    end

  end
end