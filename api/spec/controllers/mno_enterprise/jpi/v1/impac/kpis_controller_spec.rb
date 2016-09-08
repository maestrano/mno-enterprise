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
    before { allow_any_instance_of(MnoEnterprise::Impac::Dashboard).to receive(:owner).and_return(user) }
    before { api_stub_for(get: "/dashboards/#{dashboard.id}", response: from_api(dashboard)) }

    let(:kpi) { build(:impac_kpi, dashboard: dashboard) }
    let(:kpi_hash) { from_api(kpi)[:data].except(:dashboard) }

    before { api_stub_for(post: "/dashboards/#{dashboard.id}/kpis", response: from_api(kpi)) }
    before { api_stub_for(get: "/dashboards/#{dashboard.id}/kpis", response: from_api([])) }


    describe 'POST #create' do
      subject { post :create, dashboard_id: dashboard.id, kpi: kpi_hash }
      it_behaves_like "jpi v1 authorizable action"

      it ".dashboard retrieves the correct dashboard" do
        subject
        expect(assigns(:dashboard)).to eq(dashboard)
      end

      it "creates the kpi" do
        subject
        expect(assigns(:kpi)).to eq(kpi)
      end

      it { subject; expect(response.code).to eq('200') }
      it { subject; expect(JSON.parse(response.body)).to eq(kpi_hash) }
    end

    describe 'PUT #update' do
      let(:kpi_hash) { from_api(kpi)[:data].except(:dashboard).merge(element_watched: 'New Watchable') }

      subject { put :update, id: kpi.id, kpi: kpi_hash }

      before { api_stub_for(get: "/kpis/#{kpi.id}", response: from_api(kpi)) }
      before { api_stub_for(put: "/kpis/#{kpi.id}", response: kpi_hash) }

      before { kpi.save }

      it_behaves_like "jpi v1 authorizable action"

      it "updates the kpi" do
        subject
        expect(assigns(:kpi).element_watched).to eq('New Watchable')
      end

      it { subject; expect(response.code).to eq('200') }
      it { subject; expect(JSON.parse(response.body)).to eq(kpi_hash) }
    end

    describe 'DELETE #destroy' do
      subject { delete :destroy, id: kpi.id }

      before { api_stub_for(get: "/kpis/#{kpi.id}", response: from_api(kpi)) }
      before { api_stub_for(delete: "/kpis/#{kpi.id}", response: {message: 'ok', code: 200}) }

      it_behaves_like "jpi v1 authorizable action"

      it { expect(response.code).to eq('200') }
    end
  end
end
