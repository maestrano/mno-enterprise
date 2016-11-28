require 'rails_helper'

module MnoEnterprise
  RSpec.describe Jpi::V1::Admin::UsersController, type: :routing do
    routes { MnoEnterprise::Engine.routes }

    it 'routes to #index' do
      expect(get('/jpi/v1/admin/app_user_ratings')).to route_to('mno_enterprise/jpi/v1/admin/app_user_ratings#index', format: 'json')
    end

    it 'routes to #show' do
      expect(get('/jpi/v1/admin/app_user_ratings/1')).to route_to('mno_enterprise/jpi/v1/admin/app_user_ratings#show', format: 'json', id: '1')
    end

    it 'routes to #update' do
      expect(put('/jpi/v1/admin/app_user_ratings/1')).to route_to('mno_enterprise/jpi/v1/admin/app_user_ratings#update', id: '1', format: 'json')
    end
  end
end
