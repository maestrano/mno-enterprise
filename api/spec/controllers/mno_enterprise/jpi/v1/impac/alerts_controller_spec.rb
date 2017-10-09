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
    let!(:user) { build(:user) }
    let!(:current_user_stub) { stub_user(user) }

    before { sign_in user }

    let(:kpi) { build(:impac_kpi) }
    let(:alert) { build(:impac_alert, kpi: kpi, recipients: [build(:user)]) }
    let(:alert_hash) { serialize_type(alert).except(:kpi) }

    describe 'GET #index' do
      before { stub_api_v2(:get, "/alerts", alert, [:recipients], { filter: { 'recipient.id': user.id } }) }
      subject { get :index }
      it { is_expected.to be_success }
    end

    describe 'POST #create' do

      before do
        stub_api_v2(:post, '/alerts', alert)
        stub_api_v2(:get, "/kpis/#{kpi.id}", kpi)
        stub_api_v2(:patch, "/alerts/#{alert.id}/update_recipients", alert)
        stub_api_v2(:get, "/alerts/#{alert.id}", alert, [:recipients])
      end

      subject { post :create, kpi_id: kpi.id, alert: alert_hash }

      # TODO: Add authorization
      # it_behaves_like 'jpi v1 authorizable action'

      it { is_expected.to be_success }
    end

    describe 'PUT #update' do
      before do
        stub_api_v2(:get, "/alerts/#{alert.id}", alert)
        stub_api_v2(:patch, "/alerts/#{alert.id}", updated_alert)
        stub_api_v2(:get, "/alerts/#{alert.id}", alert, [:recipients])
      end

      let(:update_alert_hash) { { title: 'test', webhook: 'test', sent: true, forbidden: 'test' } }
      let(:updated_alert) { build(:impac_alert, id: alert.id, kpi_id: kpi.id, title: 'test', webhook: 'test', sent: true) }

      subject { put :update, id: alert.id, alert: update_alert_hash }

      # TODO: Add and test authorization
      # it_behaves_like "jpi v1 authorizable action"

      # TODO: Test that rendering is equal to update_alert_hash
      it { is_expected.to be_success }
    end

    describe 'DELETE #destroy' do
      before { stub_api_v2(:get, "/alerts/#{alert.id}", alert) }
      before { stub_api_v2(:delete, "/alerts/#{alert.id}") }

      subject { delete :destroy, id: alert.id }
      # TODO: Add and test authorization
      # it_behaves_like "jpi v1 authorizable action"

      it { is_expected.to be_success }
      it { subject; expect(JSON.parse(response.body)).to eq({ 'deleted' => { 'service' => alert.service } }) }
    end
  end
end
