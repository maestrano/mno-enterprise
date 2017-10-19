require 'rails_helper'

module MnoEnterprise
  RSpec.describe Jpi::V2::OrganizationsController, type: :routing do
    routes { MnoEnterprise::Engine.routes }

    it 'routes to #index' do
      expect(get('/jpi/v2/organizations')).to route_to('mno_enterprise/jpi/v2/organizations#index')
    end

    it 'routes to #show' do
      expect(get('/jpi/v2/organizations/1')).to route_to('mno_enterprise/jpi/v2/organizations#show', id: '1')
    end

    it 'routes to #create' do
      expect(post('/jpi/v2/organizations')).to route_to('mno_enterprise/jpi/v2/organizations#create')
    end

    it 'routes to #update' do
      expect(put('/jpi/v2/organizations/1')).to route_to('mno_enterprise/jpi/v2/organizations#update', id: '1')
      expect(patch('/jpi/v2/organizations/1')).to route_to('mno_enterprise/jpi/v2/organizations#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete('/jpi/v2/organizations/1')).to route_to('mno_enterprise/jpi/v2/organizations#destroy', id: '1')
    end
  end
end

