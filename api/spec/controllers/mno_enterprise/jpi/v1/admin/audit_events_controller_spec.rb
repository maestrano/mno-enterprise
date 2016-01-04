require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::Admin::AuditEventsController, type: :controller do
    include MnoEnterprise::TestingSupport::JpiV1TestHelper
    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env["HTTP_ACCEPT"] = 'application/json' }

    #===============================================
    # Assignments
    #===============================================
    # Stub controller ability
    # let!(:ability) { stub_ability }
    # before { allow(ability).to receive(:can?).with(any_args).and_return(true) }

    # # Stub user and user call
    let(:user) { FactoryGirl.build(:user, :admin) }
    before do
      api_stub_for(get: "/users/#{user.id}", response: from_api(user))
      api_stub_for(put: "/users/#{user.id}", response: from_api(user))
    end
    # before { api_stub_for(get: '/users?filter%5Bemail%5D&limit=1', response: from_api(nil)) }

    before { sign_in user }

    let(:audit_event) { FactoryGirl.build(:audit_event) }
    before { api_stub_for(get: '/audit_events', response: from_api([audit_event]))}

    describe 'GET #index' do
      subject { get :index }

      # TODO it_behaves_like for admin
      # it_behaves_like 'jpi v1 protected action'

      it 'is successful' do
        subject
        expect(response).to be_success
      end

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
