require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::Impac::KpisController, type: :controller do
    include JpiV1TestHelper
    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env["HTTP_ACCEPT"] = 'application/json' }
    
    # Stub ability
    let!(:ability) { stub_ability }
    # before { allow(ability).to receive(:can?).with(any_args).and_return(true) }
    
    # Stub user and user call
    let!(:user) { build(:user) }
    before { api_stub_for(get: "/users/#{user.id}", response: from_api(user)) }
    before { sign_in user }
    
    let(:dashboard) { build(:impac_dashboard) }
    before { allow_any_instance_of(MnoEnterprise::Impac::Dashboard).to receive(:owner).and_return(user) }
    before { api_stub_for(get: "/dashboards/#{dashboard.id}", response: from_api(dashboard)) }    

    let(:kpi) { build(:impac_kpi, dashboard: dashboard) }
    before { api_stub_for(post: "/kpis", response: from_api(kpi)) }    

    describe '#create' do

      subject { post :create, dashboard_id: dashboard.id }

      it_behaves_like "jpi v1 authorizable action"
    
    end
  end
end