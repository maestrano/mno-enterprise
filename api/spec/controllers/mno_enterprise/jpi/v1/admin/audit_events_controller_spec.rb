require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::Admin::AuditEventsController, type: :controller do
    include MnoEnterprise::TestingSupport::SharedExamples::JpiV1Admin

    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env['HTTP_ACCEPT'] = 'application/json' }

    #===============================================
    # Assignments
    #===============================================
    # Stub user and user call
    let(:user) { build(:user, :admin) }
    let!(:current_user_stub) { stub_user(user) }
    before { sign_in user }

    let(:audit_event) { build(:audit_event, user: build(:user), organization: build(:organization)) }
    let!(:audit_events_stub) { stub_api_v2(:get, '/audit_events', audit_event, [:user, :organization]) }

    describe 'GET #index' do
      subject { get :index }
      it_behaves_like 'a jpi v1 admin action'
      it_behaves_like "an unauthorized route for support users"
      context 'success' do
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
