require 'rails_helper'

module MnoEnterprise
  describe ImpersonateController, type: :controller do
    render_views
    routes { MnoEnterprise::Engine.routes }
    # Stub model calls
    let(:user) { build(:user, :admin) }
    let(:user2) { build(:user) }
    before do
      stub_api_v2(:get, "/users/#{user.id}", user)
      stub_api_v2(:get, "/users/#{user.id}", user, %i(user_access_requests))
      stub_api_v2(:get, "/users/#{user2.id}", user2, %i(user_access_requests))
      stub_api_v2(:patch, "/users/#{user.id}")
      stub_api_v2(:patch, "/users/#{user2.id}")
    end
    before { stub_audit_events }

    context 'admin user' do
      before do
        sign_in user
      end

      describe '#create' do
        subject { get :create, user_id: user2.id }
        it do
          expect(controller.current_user.id).to eq(user.id)
          subject
          expect(controller.current_user.id).to eq(user2.id)
        end

        context 'with an organisation id in parameters' do
          subject { get :create, user_id: user2.id, dhbRefId: 10 }

          it { is_expected.to redirect_to('/dashboard/#!?dhbRefId=10') }
        end

        context 'when the user does not exist' do
          before { stub_api_v2(:get, '/users/crappyId', [], %i(user_access_requests)) }
          subject { get :create, user_id: 'crappyId', dhbRefId: 10 }
          it do
            is_expected.to redirect_to('/admin/#!?flash=%7B%22msg%22%3A%22User+does+not+exist%22%2C%22type%22%3A%22error%22%7D')
          end
        end

        context 'when the user is a staff member' do
          let(:user2) { build(:user, admin_role: 'staff') }
          it do
            is_expected.to redirect_to('/admin/#!?flash=%7B%22msg%22%3A%22User+is+a+staff+member%22%2C%22type%22%3A%22error%22%7D')
          end
        end

        context 'when impersonation consent is required' do
          before { Settings.merge!(admin_panel: { impersonation: { consent_required: true } }) }
          after { Settings.merge!(admin_panel: { impersonation: { consent_required: false } }) }
          let(:user2) { build(:user, user_access_requests: [user_access_request]) }
          let(:user_access_request) { build(:user_access_request, requester_id: nil, status: status) }
          subject { get :create, user_id: user2.id }

          context 'when the impersonification is allowed' do
            let(:status) { 'approved' }
            it { is_expected.to redirect_to('/dashboard/') }
          end

          context 'when the impersonification is not allowed' do
            let(:status) { 'revoked' }
            it do
              is_expected.to redirect_to('/admin/#!?flash=%7B%22msg%22%3A%22Access+was+not+granted+or+was+revoked.%22%2C%22type%22%3A%22error%22%7D')
            end
          end
        end
      end

      describe '#destroy' do
        subject { get :destroy }
        context 'without redirect_path' do
          before { get :create, user_id: user2.id }
          it { expect(controller.current_user.id).to eq(user2.id) }
          it { subject; expect(controller.current_user.id).to eq(user.id) }
          it { is_expected.to redirect_to('/admin/') }
        end
        context 'with a redirect_path' do
          before { get :create, user_id: user2.id, redirect_path: '/admin/redirect#path' }
          it { is_expected.to redirect_to('/admin/redirect#path') }
        end
      end
    end
  end
end
