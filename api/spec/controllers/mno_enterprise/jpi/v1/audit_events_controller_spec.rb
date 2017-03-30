require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::AuditEventsController, type: :controller do
    include MnoEnterprise::TestingSupport::JpiV1TestHelper

    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env["HTTP_ACCEPT"] = 'application/json' }

    #===============================================
    # Assignments
    #===============================================
    # Stub controller ability
    let!(:ability) { stub_ability }
    before { allow(ability).to receive(:can?).with(any_args).and_return(true) }

    # Stub user and mnoe API calls
    let(:user) { FactoryGirl.build(:user, :with_organizations) }
    let(:organization) { user.organizations.first }
    let(:audit_event) { FactoryGirl.build(:audit_event) }

    before do
      api_stub_for(get: "/users/#{user.id}", response: from_api(user))
      api_stub_for(get: "/organizations/#{organization.id}", response: from_api(organization))
      api_stub_for(get: '/audit_events', response: from_api([audit_event]))
      sign_in user
    end

    describe 'GET #index' do
      subject { get :index, organization_id: organization.id }

      it_behaves_like "jpi v1 protected action"

      context 'sucess' do
        it 'assigns @audit_events' do
          subject
          expect(assigns(:audit_events).to_a).to eq([audit_event])
        end

        it 'renders the :index view' do
          subject
          expect(response).to render_template :index
        end
      end
    end
  end
end
