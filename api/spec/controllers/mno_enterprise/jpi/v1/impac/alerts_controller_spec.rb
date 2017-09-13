require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::Impac::AlertsController, type: :controller do
    include MnoEnterprise::TestingSupport::JpiV1TestHelper
    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env["HTTP_ACCEPT"] = 'application/json' }

    # Stub ability
    let!(:ability) { stub_ability }
    before { allow(ability).to receive(:can?).with(any_args).and_return(true) }

    # Stub user and user call
    let!(:user) { build(:user, alerts: [alert]) }
    let!(:current_user_stub) { stub_user(user) }


    before { sign_in user }

    let(:kpi) { build(:impac_kpi) }
    let(:alert) { build(:impac_alert, kpi: kpi) }
    let(:alert_hash) { serialize_type(alert).except(:kpi) }

    describe 'GET #index' do
      before { stub_api_v2(:get, "/users/#{user.id}", user, %i(alerts)) }
      subject { get :index }
      # TODO: Add and test authorization
    end

    describe 'POST #create' do

      before { stub_api_v2(:post, '/alerts', alert) }
      before { stub_api_v2(:get, "/kpis/#{kpi.id}", kpi) }
      subject { post :create, kpi_id: kpi.id, alert: alert_hash }

      # TODO: Add authorization
      # it_behaves_like 'jpi v1 authorizable action'

      it { subject; expect(response.code).to eq('200') }
    end

    describe 'PUT #update' do
      let(:update_alert_hash) { {title: 'test', webhook: 'test', sent: true, forbidden: 'test', } }
      let(:updated_alert) { build(:impac_alert, kpi_id: kpi.id, title: 'test', webhook: 'test', sent: true) }

      before { stub_api_v2(:get, "/alerts/#{alert.id}", alert) }
      before { stub_api_v2(:patch, "/alerts/#{alert.id}", updated_alert) }

      subject { put :update, id: alert.id, alert: update_alert_hash }

      # TODO: Add and test authorization
      # it_behaves_like "jpi v1 authorizable action"

      # TODO: Test that rendering is equal to update_alert_hash

      it { subject; expect(response.code).to eq('200') }
    end

    describe 'DELETE #destroy' do
      before { stub_api_v2(:get, "/alerts/#{alert.id}", alert) }
      before { stub_api_v2(:delete, "/alerts/#{alert.id}") }

      subject { delete :destroy, id: alert.id }
      # TODO: Add and test authorization
      # it_behaves_like "jpi v1 authorizable action"

      it { subject; expect(response.code).to eq('200') }
      it { subject; expect(JSON.parse(response.body)).to eq({'deleted' => {'service' => alert.service}}) }
    end
  end
end
