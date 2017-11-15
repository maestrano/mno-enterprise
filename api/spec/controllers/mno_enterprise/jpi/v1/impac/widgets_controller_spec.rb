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
    let!(:organization) { build(:organization) }
    let!(:orga_relation) { build(:orga_relation) }
    let!(:current_user_stub) { stub_user(user) }

    before { sign_in user }
    before { stub_orga_relation(user, organization, orga_relation, 'uid') }

    describe 'GET index' do

      let!(:widget) { build(:impac_widget, settings: { organization_ids: [organization.uid] }) }

      subject { get :index, organization_id: organization.uid }

      before { stub_api_v2(:get, '/organizations', [organization], [], { filter: { uid: organization.uid } }) }
      before { stub_api_v2(:get, '/widgets', [widget], [], { filter: { 'organization.id': organization.id } }) }
      it 'returns the widgets' do
        subject
        expect(JSON.parse(response.body)).to eq({ 'widgets' => [
          { 'id' => widget.id, 'endpoint' => widget.endpoint, 'settings' => { 'organization_ids' => [organization.uid] } }
        ] })
      end
    end
  end

end
