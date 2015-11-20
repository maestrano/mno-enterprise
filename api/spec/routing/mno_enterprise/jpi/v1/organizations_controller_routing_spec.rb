require 'rails_helper'

module MnoEnterprise
  RSpec.describe Jpi::V1::OrganizationsController, type: :routing do
    routes { MnoEnterprise::Engine.routes }
    
    it 'routes to #index' do
      expect(get('/jpi/v1/organizations')).to route_to("mno_enterprise/jpi/v1/organizations#index")
    end
    
    it 'routes to #show' do
      expect(get('/jpi/v1/organizations/1')).to route_to("mno_enterprise/jpi/v1/organizations#show", id: '1')
    end
    
    it 'routes to #create' do
      expect(post('/jpi/v1/organizations')).to route_to("mno_enterprise/jpi/v1/organizations#create")
    end
    
    it 'routes to #update' do
      expect(put('/jpi/v1/organizations/1')).to route_to("mno_enterprise/jpi/v1/organizations#update", id: '1')
    end
    
    it "routes to #update_billing" do
      expect(put("/jpi/v1/organizations/1/update_billing")).to route_to("mno_enterprise/jpi/v1/organizations#update_billing",id: '1')
    end
    
    it "routes to #invite_members" do
      expect(put("/jpi/v1/organizations/1/invite_members")).to route_to("mno_enterprise/jpi/v1/organizations#invite_members",id: '1')
    end

    it "routes to #update_member" do
      expect(put("/jpi/v1/organizations/1/update_member")).to route_to("mno_enterprise/jpi/v1/organizations#update_member",id: '1')
    end

    it "routes to #remove_member" do
      expect(put("/jpi/v1/organizations/1/remove_member")).to route_to("mno_enterprise/jpi/v1/organizations#remove_member",id: '1')
    end
  end
end

