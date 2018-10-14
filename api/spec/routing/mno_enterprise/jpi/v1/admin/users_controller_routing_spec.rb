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

    it 'routes to #metrics' do
      expect(get('/jpi/v1/admin/users/metrics')).to route_to("mno_enterprise/jpi/v1/admin/users#metrics", format: 'json')
    end

    describe 'support routes' do
      before do
        Settings.merge!(admin_panel: {support: {enabled: enabled}})
        Rails.application.reload_routes!
      end

      context 'when support is enabled' do
        let(:enabled) { true }

        it 'adds support routes' do
          expect(post('/jpi/v1/admin/users/1/login_with_org_external_id')).to route_to("mno_enterprise/jpi/v1/admin/users#login_with_org_external_id", id: '1', format: 'json')
        end

        it 'routes to #signup_email' do
          expect(delete('/jpi/v1/admin/users/1/logout_support')).to route_to("mno_enterprise/jpi/v1/admin/users#logout_support", id: '1', format: 'json')
        end
      end

      context 'when support is disabled' do
        let(:enabled) { false }

        it 'adds support routes' do
          expect(post('/jpi/v1/admin/users/1/login_with_org_external_id')).not_to be_routable
        end

        it 'routes to #signup_email' do
          expect(delete('/jpi/v1/admin/users/1/logout_support')).not_to be_routable
        end
      end
    end
  end
end
