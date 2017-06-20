require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::Impac::KpisController, type: :controller do
    include MnoEnterprise::TestingSupport::JpiV1TestHelper
    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env['HTTP_ACCEPT'] = 'application/json' }

    # Stub ability
    let!(:ability) { stub_ability }
    before { allow(ability).to receive(:can?).with(any_args).and_return(true) }

    # Stub user and user call
    let!(:user) { build(:user) }
    let!(:current_user_stub) { stub_api_v2(:get, "/users/#{user.id}", user, %i(deletion_requests organizations orga_relations dashboards)) }

    before { sign_in user }

    let(:dashboard) { build(:impac_dashboard) }

    # TODO KPI DISABLED TEST CASES

    let(:kpi_targets) { {evolution: [{max: '20'}]} }
    let(:settings) { {} }
    let(:extra_params) { [] }
    let(:kpi) { build(:impac_kpi, dashboard: dashboard, targets: kpi_targets, settings: settings, extra_params: extra_params) }
    let(:kpi_hash) { serialize_type(kpi).except(:dashboard) }

    let(:alert) { build(:impac_alert, kpi_id: kpi.id) }
    let(:alerts_hashes) { [serialize_type(alert)] }

    describe 'GET index' do
      let(:params) { {'metadata' => {'organization_ids' => ['some_id']}, 'opts' => {'some' => 'opts'}} }
      subject { get :index, metadata: params['metadata'], opts: params['opts'] }

      let(:impac_available_kpis) do
        [
          {"name" => "Debtor Due Days", "endpoint" => "invoicing/due_days/debtor", "watchables" => ["max", "average"], "attachables" => nil, "target_placeholders" => {"max" => {"mode" => "max", "value" => 90, "unit" => "days"}, "average" => {"mode" => "max", "value" => 30, "unit" => "days"}}},
          {"name" => "Account Balance", "endpoint" => "accounting/balance", "watchables" => ["balance"], "attachables" => ["accounts/balance"], "target_placeholders" => {"balance" => {"mode" => "min", "value" => 15000, "unit" => "currency"}}}
        ]
      end

      let(:expected_result) do
        {
          "kpis" => [
            {"name" => "Debtor Due Days Max", "endpoint" => "invoicing/due_days/debtor", "watchables" => ["max"], "attachables" => nil, "target_placeholders" => {"max" => {"mode" => "max", "value" => 90, "unit" => "days"}}},
            {"name" => "Debtor Due Days Average", "endpoint" => "invoicing/due_days/debtor", "watchables" => ["average"], "attachables" => nil, "target_placeholders" => {"average" => {"mode" => "max", "value" => 30, "unit" => "days"}}},
            {"name" => "Account Balance", "endpoint" => "accounting/balance", "watchables" => ["balance"], "attachables" => ["accounts/balance"], "target_placeholders" => {"balance" => {"mode" => "min", "value" => 15000, "unit" => "currency"}}},
          ]
        }
      end

      let(:auth) { {username: 'username', password: 'password'} }
      before { allow(MnoEnterprise::ImpacClient).to receive(:send_get).with('/api/v2/kpis', params, basic_auth: auth).and_return('kpis' => impac_available_kpis) }
      before { allow(MnoEnterprise).to receive(:tenant_id).and_return(auth[:username]) }
      before { allow(MnoEnterprise).to receive(:tenant_key).and_return(auth[:password]) }

      it { subject; expect(response).to have_http_status(:ok) }

      it 'successfully discovers and customises available kpis' do
        expect(MnoEnterprise::ImpacClient).to receive(:send_get)
        subject
        expect(JSON.parse(response.body)).to eq(expected_result)
      end

      context 'when impac api request raises an error' do
        before { allow(MnoEnterprise::ImpacClient).to receive(:send_get).and_raise }

        it 'rescues responding with an error message' do
          subject
          expect(JSON.parse(response.body)).to include('message')
        end
      end
    end

    describe 'POST #create' do
      shared_examples "create kpi action" do

        xit "creates the kpi" do
          subject
          # TODO: check that the rendered kpi is the created one
          expect(assigns(:kpi)).to eq(kpi)
        end

        context "when there are kpi targets" do
          let(:kpi_targets) { { evolution: [{max: "20"}] } }

          before do
            stub_api_v2(:post, "/alerts", alert)
          end

          xit "creates kpi alerts" do
            subject
            # TODO: Check that the alerts are rendered
            expect(assigns(:kpi).alerts).to eq([alert])
            expect(response).to have_http_status(:ok)
          end
        end

        it { subject; expect(response).to have_http_status(:ok) }
      end

      let (:kpi_targets) { {} }

      context "a dashboard KPI" do
        subject { post :create, dashboard_id: dashboard.id, kpi: kpi_hash }
        let(:created_kpi) { build(:impac_kpi) }
        before do
          stub_api_v2(:get, "/dashboards/#{dashboard.id}", dashboard)
          stub_api_v2(:post, "/kpis", created_kpi)
          stub_api_v2(:post, "/alerts")
          # kpi reload
          stub_api_v2(:get, "/kpis/#{created_kpi.id}", [created_kpi], [:alerts])
        end

        it_behaves_like 'jpi v1 authorizable action'

        it_behaves_like 'create kpi action'

        it '.dashboard retrieves the correct dashboard' do
          subject
        end
      end

      context "a widget KPI" do
        let(:widget) { build(:impac_widget) }
        let(:created_kpi) { build(:impac_kpi) }
        subject { post :create, dashboard_id: dashboard.id, kpi: kpi_hash.merge(widget_id: widget.id) }

        before do
          stub_api_v2(:get, "/widgets/#{widget.id}", widget)
          stub_api_v2(:post, "/kpis", created_kpi)
          stub_api_v2(:post, "/alerts")
          # kpi reload
          stub_api_v2(:get, "/kpis/#{created_kpi.id}", [created_kpi], [:alerts])
        end

        it_behaves_like 'jpi v1 authorizable action'

        it_behaves_like 'create kpi action'

        xit '.widget retrieves the correct widget' do
          subject
          # TODO: check that the widget is well rendered
          expect(assigns(:widget)).to eq(widget)
        end
      end
    end

    describe 'PUT #update' do
      RSpec.shared_examples 'a kpi update action' do
        it 'updates the kpi' do
          subject
          expect(assigns(:kpi).element_watched).to eq('New Watchable')
          expect(response).to have_http_status(:ok)
        end

        context 'target set for the first time' do
          let(:kpi_targets) { nil }
          let(:params) { {targets: {evolution: [{max: '20'}]}} }

          before do
            stub_api_v2(:post, '/alerts')
          end

          it 'creates an alert' do
            subject
            assert_requested_api_v2(:post, '/alerts', times: 1)
            expect(response.code).to eq('200')
          end
        end

        context 'when a kpi has no targets, nor is being updated with any' do
          let(:kpi_targets) { nil }
          let(:params) { {targets: {}} }

          before { stub_api_v2(:delete, "/alerts/#{alert.id}") }

          it "destroys the kpi's alerts" do
            subject
            assert_requested_api_v2(:delete, "/alerts/#{alert.id}", times: 1)
            expect(response.code).to eq('200')
          end
        end

        context 'when targets have changed' do
          let!(:alert) { build(:impac_alert, kpi_id: kpi.id, sent: true) }
          let(:params) { {targets: {evolution: [{max: '30'}]}} }

          it "updates the sent status of all the kpi's alerts" do
            subject
            assert_requested_api_v2(:patch, "/alerts/#{alert.id}", times: 1)
            expect(response.code).to eq('200')
          end
        end

        context 'when no targets are given / targets are nil' do
          let(:kpi) { build(:impac_kpi, dashboard: dashboard, targets: kpi_targets, settings: {currency: 'GBP'}) }
          let(:params) { {targets: nil} }

          it 'does not remove the kpi targets' do
            subject
            expect(assigns(:kpi).targets).to eq(kpi_targets.deep_stringify_keys)
            expect(response).to have_http_status(:ok)
          end
        end

        context 'when no extra_params are given / extra_params are nil' do
          let(:kpi) { build(:impac_kpi, dashboard: dashboard, targets: kpi_targets, extra_params: ['some-param'], settings: {currency: 'GBP'}) }
          let(:updated_kpi) { build(:impac_kpi, id: kpi.id, targets: kpi_targets, extra_params: ['some-param'], settings: {currency: 'GBP'}) }
          let(:params) { {extra_params: nil} }

          it 'does not remove the kpi extra_params' do
            subject
            expect(assigns(:kpi).extra_params).to eq(['some-param'])
            expect(response).to have_http_status(:ok)
          end
        end
      end

      let(:kpi_hash) { serialize_type(kpi).except(:dashboard).merge(element_watched: 'New Watchable') }
      let(:params) { {} }
      let(:updated_kpi) { build(:impac_kpi, id: kpi.id, element_watched: 'New Watchable', targets: kpi_targets)}
      subject { put :update, id: kpi.id, kpi: kpi_hash.merge(params) }

      before {
        kpi.alerts << alert
        updated_kpi.alerts << alert
        # reload of the kpi
        stub_api_v2(:get, "/kpis/#{kpi.id}", updated_kpi, %i(dashboard alerts))
        stub_api_v2(:patch, "/kpis/#{kpi.id}", updated_kpi)
        stub_api_v2(:patch, "/alerts/#{alert.id}", alert)
      }

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

      before {
        stub_api_v2(:get, "/kpis/#{kpi.id}", kpi, %i(dashboard alerts))
        stub_api_v2(:delete, "/kpis/#{kpi.id}")
      }

      it_behaves_like 'jpi v1 authorizable action'

      it 'calls delete' do
        subject
        expect(response.code).to eq('200')
        assert_requested_api_v2(:delete, "/kpis/#{kpi.id}", times: 1)
      end
    end
  end
end
