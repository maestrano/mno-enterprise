require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::Admin::AuditEventsController, type: :controller do
    include MnoEnterprise::TestingSupport::SharedExamples::JpiV1Admin

    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env["HTTP_ACCEPT"] = 'application/json' }

    #===============================================
    # Assignments
    #===============================================
    # Stub user and user call
    let(:user) { FactoryGirl.build(:user, :admin) }
    before { api_stub_for(get: "/users/#{user.id}", response: from_api(user)) }
    before { sign_in user }

    let(:audit_event) { FactoryGirl.build(:audit_event) }
    before { api_stub_for(get: '/audit_events', response: from_api([audit_event]))}

    describe 'GET #index' do
      subject { get :index }

      it_behaves_like 'a jpi v1 admin action'

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

      context 'csv' do
        before { request.env["HTTP_ACCEPT"] = 'text/csv' }

        it 'renders the :index view' do
          subject
          expect(response).to render_template :index
        end
      end
    end
  end
end
