require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::AuditEventsController, type: :controller do
    include MnoEnterprise::TestingSupport::JpiV1TestHelper

    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env['HTTP_ACCEPT'] = 'application/json' }

    #===============================================
    # Assignments
    #===============================================
    # Stub controller ability
    let!(:ability) { stub_ability }
    before { allow(ability).to receive(:can?).with(any_args).and_return(true) }

    # Stub user and mnoe API calls
    let(:user) { build(:user) }
    let!(:organization) {
      o = build(:organization, orga_relations: [])
      o.orga_relations << build(:orga_relation, user_id: user.id, organization_id: o.id, role: "Super Admin")
      o
    }
    let(:audit_event) { build(:audit_event) }

    let!(:current_user_stub) { stub_user(user) }
    before { stub_api_v2(:get, "/organizations/#{organization.id}", organization, %i(orga_relations users)) }
    before { stub_api_v2(:get, "/organizations/#{organization.id}", organization) }
    before do
      stub_api_v2(:get, '/audit_events', [audit_event], [], {filter: {organization_id: organization.id}})
      sign_in user
    end

    describe 'GET #index' do
      subject { get :index, organization_id: organization.id }

      it_behaves_like 'jpi v1 protected action'

      context 'success' do
        it 'assigns @audit_events' do
          subject
          # TODO: Check fields assignation from response
          # expect(assigns(:audit_events).to_a).to eq([audit_event])
        end

        it 'renders the :index view' do
          subject
          expect(response).to render_template :index
        end
      end
    end
  end
end
