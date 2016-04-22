require 'rails_helper'

module MnoEnterprise
  RSpec.describe Jpi::V1::Admin::UsersController, type: :routing do
    routes { MnoEnterprise::Engine.routes }

    it 'routes to #index' do
      expect(get('/jpi/v1/admin/users')).to route_to("mno_enterprise/jpi/v1/admin/users#index", format: "json")
    end

    it 'routes to #show' do
      expect(get('/jpi/v1/admin/users/1')).to route_to("mno_enterprise/jpi/v1/admin/users#show", format: "json", id: '1')
    end

    it 'routes to #update' do
      expect(put('/jpi/v1/admin/users/1')).to route_to("mno_enterprise/jpi/v1/admin/users#update", id: '1', format: 'json')
    end

    it 'routes to #destroy' do
      expect(delete('/jpi/v1/admin/users/1')).to route_to("mno_enterprise/jpi/v1/admin/users#destroy", id: '1', format: 'json')
    end

    it 'routes to #count' do
      expect(get('/jpi/v1/admin/users/count')).to route_to("mno_enterprise/jpi/v1/admin/users#count", format: 'json')
    end

    it 'routes to #signup_email' do
      expect(post('/jpi/v1/admin/users/signup_email')).to route_to("mno_enterprise/jpi/v1/admin/users#signup_email", format: 'json')
    end
  end
end
