require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::Impac::KpisController, type: :controller do
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

    let(:dashboard) { build(:impac_dashboard) }

    # TODO KPI DISABLED TEST CASES

    # Stub the dashboard owner
    before { allow_any_instance_of(MnoEnterprise::Impac::Dashboard).to receive(:owner).and_return(user) }

    let(:kpi_targets) { { evolution: [{max: "20"}] } }
    let(:settings) { {} }
    let(:extra_params) { [] }
    let(:kpi) { build(:impac_kpi, dashboard: dashboard, targets: kpi_targets, settings: settings, extra_params: extra_params) }
    let(:kpi_hash) { from_api(kpi)[:data].except(:dashboard) }

    let(:alert) { build(:impac_alert, kpi: kpi) }
    let(:alerts_hashes) { [from_api(alert)[:data]] }

    describe 'GET index' do
      let(:params) { { 'metadata' => {'organization_ids' => ['some_id']}, 'opts' => {'some' => 'opts'} } }
      subject { get :index, metadata: params['metadata'], opts: params['opts'] }

      let(:impac_available_kpis) do
        [
          {"name"=>"Debtor Due Days", "endpoint"=>"invoicing/due_days/debtor", "watchables"=>["max", "average"], "attachables"=>nil, "target_placeholders"=>{"max"=>{"mode"=>"max", "value"=>90, "unit"=>"days"}, "average"=>{"mode"=>"max", "value"=>30, "unit"=>"days"}}},
          {"name"=>"Account Balance", "endpoint"=>"accounting/balance", "watchables"=>["balance"], "attachables"=>["accounts/balance"], "target_placeholders"=>{"balance"=>{"mode"=>"min", "value"=>15000, "unit"=>"currency"}}}
        ]
      end

      let(:expected_result) do
        {
          "kpis" => [
            {"name"=>"Debtor Due Days Max", "endpoint"=>"invoicing/due_days/debtor", "watchables"=>["max"], "attachables"=>nil, "target_placeholders"=>{"max"=>{"mode"=>"max", "value"=>90, "unit"=>"days"}}},
            {"name"=>"Debtor Due Days Average", "endpoint"=>"invoicing/due_days/debtor", "watchables"=>["average"], "attachables"=>nil, "target_placeholders"=>{"average"=>{"mode"=>"max", "value"=>30, "unit"=>"days"}}},
            {"name"=>"Account Balance", "endpoint"=>"accounting/balance", "watchables"=>["balance"], "attachables"=>["accounts/balance"], "target_placeholders"=>{"balance"=>{"mode"=>"min", "value"=>15000, "unit"=>"currency"}}},
          ]
        }
      end

      let(:auth) { { username: 'username', password: 'password' } }
      before { allow(MnoEnterprise::ImpacClient).to receive(:send_get).with('/api/v2/kpis', params, basic_auth: auth).and_return('kpis' => impac_available_kpis) }
      before { allow(MnoEnterprise).to receive(:tenant_id).and_return(auth[:username]) }
      before { allow(MnoEnterprise).to receive(:tenant_key).and_return(auth[:password]) }

      it { subject; expect(response).to have_http_status(:ok) }

      it "successfully discovers and customises available kpis" do
        expect(MnoEnterprise::ImpacClient).to receive(:send_get)
        subject
        expect(JSON.parse(response.body)).to eq(expected_result)
      end

      context "when impac api request raises an error" do
        before { allow(MnoEnterprise::ImpacClient).to receive(:send_get).and_raise }

        it "rescues responding with an error message" do
          subject
          expect(JSON.parse(response.body)).to include('message')
        end
      end
    end

    describe 'POST #create' do
      shared_examples "create kpi action" do
        it "creates the kpi" do
          subject
          expect(assigns(:kpi)).to eq(kpi)
        end

        it { subject; expect(response).to have_http_status(:ok) }
      end

      let (:kpi_targets) { {} }

      before { allow(ability).to receive(:can?).with(:create_impac_kpis, any_args).and_return(true) }

      context "a dashboard KPI" do
        subject { post :create, dashboard_id: dashboard.id, kpi: kpi_hash }

        before do
          api_stub_for(get: "/dashboards/#{dashboard.id}", response: from_api(dashboard))
          api_stub_for(post: "/dashboards/#{dashboard.id}/kpis", response: from_api(kpi))
          api_stub_for(get: "/dashboards/#{dashboard.id}/kpis", response: from_api([]))
          api_stub_for(get: "/kpis/#{kpi.id}", response: from_api(kpi)) # kpi.reload
          # TODO: this call should not happen as alerts should be wrapped into the kpi object
          api_stub_for(get: "/kpis/#{kpi.id}/alerts", response: from_api(alerts_hashes))
        end

        it_behaves_like "jpi v1 authorizable action"

        it_behaves_like "create kpi action"

        it ".dashboard retrieves the correct dashboard" do
          subject
          expect(assigns(:dashboard)).to eq(dashboard)
        end

        context "when there are kpi targets" do
          let(:kpi_targets) { { evolution: [{max: "20"}] } }

          before do
            api_stub_for(post: "/users/#{user.id}/alerts", response: from_api(alert))
            api_stub_for(get: "/users/#{user.id}/alerts", response: from_api({}))
          end

          it "creates a kpi inapp alert" do
            subject
            expect(assigns(:kpi).alerts).to eq([alert])
            expect(response).to have_http_status(:ok)
          end
        end
      end

      context "a widget KPI" do
        let(:widget) { build(:impac_widget) }
        subject { post :create, dashboard_id: dashboard.id, kpi: kpi_hash.merge(widget_id: widget.id) }

        before do
          api_stub_for(get: "/widgets/#{widget.id}", response: from_api(widget))
          api_stub_for(post: "/widgets/#{widget.id}/kpis", response: from_api(kpi))
          api_stub_for(get: "/widgets/#{widget.id}/kpis", response: from_api([]))
          api_stub_for(get: "/kpis/#{kpi.id}", response: from_api(kpi)) # kpi.reload
          # TODO: this call should not happen as alerts should be wrapped into the kpi object
          api_stub_for(get: "/kpis/#{kpi.id}/alerts", response: from_api(alerts_hashes))
        end

        it_behaves_like "jpi v1 authorizable action"

        it_behaves_like "create kpi action"

        it ".widget retrieves the correct widget" do
          subject
          expect(assigns(:widget)).to eq(widget)
        end

        context "when there are kpi targets" do
          let(:kpi_targets) { { evolution: [{max: "20"}] } }

          let(:email_alert) { build(:impac_alert, kpi: kpi, service: 'email') }
          let(:alerts_hashes) { [from_api(alert)[:data], from_api(email_alert)[:data]] }

          before do
            api_stub_for(post: "/users/#{user.id}/alerts", response: from_api(alert), body: {service: 'inapp', impac_kpi_id: kpi.id})
            api_stub_for(post: "/users/#{user.id}/alerts", response: from_api(email_alert), body: {service: 'email', impac_kpi_id: kpi.id})
            api_stub_for(get: "/users/#{user.id}/alerts", response: from_api({}))
          end

          it "creates kpi alerts" do
            subject
            expect(assigns(:kpi).alerts).to eq([alert, email_alert])
            expect(response).to have_http_status(:ok)
          end
        end
      end
    end

    describe 'PUT #update' do
      subject { put :update, id: kpi.id, kpi: kpi_hash.merge(params) }

      RSpec.shared_examples 'a kpi update action' do
        it "updates the kpi" do
          subject
          expect(assigns(:kpi).element_watched).to eq('New Watchable')
          expect(response).to have_http_status(:ok)
        end

        context "target set for the first time" do
          let(:kpi_targets) { nil }
          let(:params) { { targets: {evolution: [{max:'20'}]} } }

          before do
            api_stub_for(post: "/users/#{user.id}/alerts", response: from_api(alert))
            api_stub_for(get: "/users/#{user.id}/alerts", response: from_api({}))
          end

          it "creates an alert" do
            subject
            expect(assigns(:kpi).alerts).to eq([alert])
            expect(response).to have_http_status(:ok)
          end
        end

        context "when targets have changed" do
          let(:alert) { build(:impac_alert, kpi: kpi, sent: true) }
          let(:params) { { targets: {evolution: [{max:'30'}]} } }

          before { api_stub_for(put: "/alerts/#{alert.id}", response: from_api({})) }

          it "updates the sent status of all the kpi's alerts" do
            subject
            expect(assigns(:kpi).alerts).to eq([alert])
            expect(response).to have_http_status(:ok)
          end
        end

        context "when no targets are given / targets are nil" do
          let(:settings) { { currency: 'GBP' } }
          let(:params) { { targets: nil } }

          it "does not remove the kpi targets" do
            subject
            expect(assigns(:kpi).targets).to eq(kpi_targets.deep_stringify_keys)
            expect(response).to have_http_status(:ok)
          end
        end

        context "when no extra_params are given / extra_params are nil" do
          let(:settings) { { currency: 'GBP' } }
          let(:extra_params) { ['some-param'] }
          let(:params) { { extra_params: nil } }

          it "does not remove the kpi extra_params" do
            subject
            expect(assigns(:kpi).extra_params).to eq(['some-param'])
            expect(response).to have_http_status(:ok)
          end
        end
      end

      let(:kpi_hash) { from_api(kpi)[:data].except(:dashboard).merge(element_watched: 'New Watchable') }
      let(:params) { {} }

      before do
        api_stub_for(get: "/kpis/#{kpi.id}", response: from_api(kpi))
        api_stub_for(put: "/kpis/#{kpi.id}", response: kpi_hash)
        api_stub_for(get: "/kpis/#{kpi.id}/alerts", response: from_api(alerts_hashes))
        allow(ability).to receive(:can?).with(:update_impac_kpis, any_args).and_return(true)
        kpi.save
      end

      context "a dashboard KPI" do
        it_behaves_like "jpi v1 authorizable action"
        it_behaves_like "a kpi update action"
      end

      context "a widget KPI" do
        let(:widget) { build(:impac_widget) }
        let(:kpi) { build(:impac_kpi, widget: widget, targets: kpi_targets, settings: settings, extra_params: extra_params) }

        it_behaves_like "jpi v1 authorizable action"
        it_behaves_like "a kpi update action"
      end
    end

    describe 'DELETE #destroy' do
      subject { delete :destroy, id: kpi.id }

      before do
        api_stub_for(get: "/kpis/#{kpi.id}", response: from_api(kpi))
        api_stub_for(delete: "/kpis/#{kpi.id}", response: {message: 'ok', code: 200})
        allow(ability).to receive(:can?).with(:destroy_impac_kpis, any_args).and_return(true)
      end

      it_behaves_like "jpi v1 authorizable action"

      it { expect(response).to have_http_status(:ok) }
    end
  end
end
