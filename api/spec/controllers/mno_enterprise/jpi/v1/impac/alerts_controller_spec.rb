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
    before { api_stub_for(get: "/users/#{user.id}", response: from_api(user)) }
    before { sign_in user }

    let(:kpi) { build(:impac_kpi) }
    let(:alert) { build(:impac_alert, kpi: kpi) }
    let(:alert_hash) { from_api(alert)[:data].except(:kpi) }

    describe 'GET #index' do
      before { api_stub_for(get: "/users/#{user.id}/alerts", response: from_api([alert])) }
      subject { get :index }
    end

    describe 'POST #create' do
      before { api_stub_for(get: "/kpis/#{kpi.id}", response: from_api(kpi)) }
      before { api_stub_for(post: "/alerts", response: from_api(alert)) }
      before { api_stub_for(get: "/alerts", response: from_api([])) }

      subject { post :create, kpi_id: kpi.id, alert: alert_hash }

      it_behaves_like "jpi v1 authorizable action"

      it "creates and assigns the alert" do
        subject
        expect(assigns(:alert)).to eq(alert)
      end

      it "attaches the alert to the kpi" do
        subject
        expect(assigns(:alert).kpi).to eq(kpi)
      end

      context "when params contains recipient_ids" do
        let(:another_recipient) { build(:user) }
        let(:alert_hash) { from_api(alert)[:data].except(:kpi).merge(recipient_ids: [user.id, another_recipient.id]) }
        let(:alert) { build(:impac_alert, kpi: kpi, recipients: [user,another_recipient]) }

        it "excludes the recipient_ids from params" do
          subject
          expect(assigns(:alert)).to eq(alert)
        end
      end

      it { subject; expect(response.code).to eq('200') }
    end

    describe 'PUT #update' do
      let(:params) { {title: 'test', webhook: 'test', sent: true, forbidden: 'test'} }
      let(:updated_alert) { build(:impac_alert, kpi: kpi, title: 'test', webhook: 'test', sent: true) }

      before { api_stub_for(get: "/alerts/#{alert.id}", response: from_api(alert)) }
      before { api_stub_for(put: "/alerts/#{alert.id}", response: from_api(updated_alert)) }

      subject { put :update, id: alert.id, alert: params }

      it_behaves_like "jpi v1 authorizable action"

      it "assigns the alert" do
        subject
        expect(assigns(:alert)).to eq(updated_alert)
      end

      it { subject; expect(response.code).to eq('200') }

      context "when updating email alert recipients" do
        let(:another_recipient) { build(:user) }
        let(:params) { { recipient_ids: [alert.recipients.first.id, another_recipient.id] } }
        let(:updated_alert) { build(:impac_alert, kpi: kpi, service: 'email', recipients: [alert.recipients.first, another_recipient]) }

        it "assigns the alert with the correct recipients" do
          subject
          expect(assigns(:alert)).to eq(updated_alert)
        end
      end
    end

    describe 'DELETE #destroy' do
      before { api_stub_for(get: "/alerts/#{alert.id}", response: from_api(alert)) }
      before { api_stub_for(get: "/kpis/#{kpi.id}", response: from_api(kpi)) }
      before { api_stub_for(delete: "/alerts/#{alert.id}", response: from_api([])) }

      subject { delete :destroy, id: alert.id }

      it_behaves_like "jpi v1 authorizable action"

      it { subject; expect(response.code).to eq('200') }
      it { subject; expect(JSON.parse(response.body)).to eq({"deleted" => {"service" => alert.service}}) }
    end
  end
end
