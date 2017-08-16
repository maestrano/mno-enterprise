require 'rails_helper'

module MnoEnterprise
  describe ImpersonateController, type: :controller do
    render_views
    routes { MnoEnterprise::Engine.routes }

    # Stub model calls
    let(:user) { build(:user, :admin) }
    let(:user2) { build(:user) }
    before do
      stub_api_v2(:get, "/users/#{user.id}", user, %i(deletion_requests organizations orga_relations dashboards))
      stub_api_v2(:get, "/users/#{user2.id}", user2, %i(deletion_requests organizations orga_relations dashboards))

      stub_api_v2(:patch, "/users/#{user.id}")
      stub_api_v2(:patch, "/users/#{user2.id}")

    end
    before { stub_audit_events }

    context 'admin user' do
      before do
        sign_in user
      end

      describe '#create' do
        it do
          expect(controller.current_user.id).to eq(user.id)
          get :create, user_id: user2.id
          expect(controller.current_user.id).to eq(user2.id)
        end

        context 'with an organisation id in parameters' do
          before { get :create, user_id: user.id, dhbRefId: 10 }

          it { is_expected.to redirect_to('/dashboard/#!?dhbRefId=10') }
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
