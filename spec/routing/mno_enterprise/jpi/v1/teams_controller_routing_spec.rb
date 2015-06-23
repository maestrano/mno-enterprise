require 'rails_helper'

module MnoEnterprise
  RSpec.describe Jpi::V1::TeamsController, type: :routing do
    routes { MnoEnterprise::Engine.routes }
    
    it 'routes to #index' do
      expect(get('/jpi/v1/organizations/1/teams')).to route_to("mno_enterprise/jpi/v1/teams#index", organization_id: '1')
    end
    
    it 'routes to #show' do
      expect(get('/jpi/v1/teams/1')).to route_to("mno_enterprise/jpi/v1/teams#show", id: '1')
    end
    
    it 'routes to #create' do
      expect(post('/jpi/v1/organizations/1/teams')).to route_to("mno_enterprise/jpi/v1/teams#create", organization_id: '1')
    end
    
    it 'routes to #update' do
      expect(put('/jpi/v1/teams/1')).to route_to("mno_enterprise/jpi/v1/teams#update", id: '1')
    end
    
    it 'routes to #add_users' do
      expect(put('/jpi/v1/teams/1/add_users')).to route_to("mno_enterprise/jpi/v1/teams#add_users", id: '1')
    end
    
    it 'routes to #remove_users' do
      expect(put('/jpi/v1/teams/1/remove_users')).to route_to("mno_enterprise/jpi/v1/teams#remove_users", id: '1')
    end
    
    it 'routes to #destroy' do
      expect(delete('/jpi/v1/teams/1')).to route_to("mno_enterprise/jpi/v1/teams#destroy", id: '1')
    end
  end
end

