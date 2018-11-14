require 'rails_helper'

module MnoEnterprise
  RSpec.describe Jpi::V2::UsersController, type: :routing do
    routes { MnoEnterprise::Engine.routes }

    it 'routes to #index' do
      expect(get('/jpi/v2/users')).to route_to('mno_enterprise/jpi/v2/users#index')
    end

    it 'routes to #show' do
      expect(get('/jpi/v2/users/1')).to route_to('mno_enterprise/jpi/v2/users#show', id: '1')
    end

    # it 'routes to #create' do
    #   expect(post('/jpi/v2/users')).to route_to('mno_enterprise/jpi/v2/users#create')
    # end
    
    it 'routes to #update' do
      expect(put('/jpi/v2/users/1')).to route_to('mno_enterprise/jpi/v2/users#update', id: '1')
      expect(patch('/jpi/v2/users/1')).to route_to('mno_enterprise/jpi/v2/users#update', id: '1')
    end
    
    # it 'routes to #destroy' do
    #   expect(delete('/jpi/v2/users/1')).to route_to('mno_enterprise/jpi/v2/users#destroy', id: '1')
    # end
  end
end

