require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::Impac::WidgetsController, type: :controller do
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

    describe 'GET index' do
      let!(:org) { build(:organization) }
      let!(:widget) { build(:impac_widget, settings: { organization_ids: [org.uid] }) }

      subject { get :index, organization_id: org.uid }

      before { api_stub_for(get: "/users/#{user.id}/organizations", response: from_api([org])) }
      before { api_stub_for(get: "/organizations/#{org.id}/widgets", response: from_api([widget])) }

      it "returns the widgets" do
        subject 
        expect(JSON.parse(response.body)).to eq({
          "widgets" => [
            {"id"=>widget.id, "endpoint"=>widget.endpoint, "settings"=>{"organization_ids"=>[org.uid]}}
          ]
        })
      end
    end
  end

end
