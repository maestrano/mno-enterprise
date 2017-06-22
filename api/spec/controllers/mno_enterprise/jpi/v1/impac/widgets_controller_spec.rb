require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::Impac::WidgetsController, type: :controller do
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

    describe 'GET index' do
      let!(:organization) {
        o = build(:organization, orga_relations: [])
        o.orga_relations << build(:orga_relation, user_id: user.id, organization_id: o.id, role: 'Super Admin')
        o
      }
      let!(:widget) { build(:impac_widget, settings: {organization_ids: [organization.uid]}) }

      subject { get :index, organization_id: organization.uid }

      before { stub_api_v2(:get, '/organizations', [organization], %i(orga_relations users), {filter: {uid: organization.uid}}) }
      before { stub_api_v2(:get, '/widgets', [widget], [], {filter: {organization_id: organization.id}}) }
      it 'returns the widgets' do
        subject
        expect(JSON.parse(response.body)).to eq({'widgets' => [
          {'id' => widget.id, 'endpoint' => widget.endpoint, 'settings' => {'organization_ids' => [organization.uid]}}
        ]})
      end
    end
  end

end
