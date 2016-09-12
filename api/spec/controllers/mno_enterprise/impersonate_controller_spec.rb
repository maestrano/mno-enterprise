require 'rails_helper'

module MnoEnterprise
  describe ImpersonateController, type: :controller do
    render_views
    routes { MnoEnterprise::Engine.routes }

    # Stub model calls
    let(:user) { build(:user, :admin) }
    let(:user2) { build(:user) }
    before do
      api_stub_for(get: "/users/#{user.id}", response: from_api(user))
      api_stub_for(put: "/users/#{user.id}", response: from_api(user))
      api_stub_for(get: "/users/#{user2.id}", response: from_api(user2))
      api_stub_for(put: "/users/#{user2.id}", response: from_api(user2))
    end

    context "admin user" do
      before do
        sign_in user
      end

      describe "#create" do
        it do
          expect(controller.current_user.id).to eq(user.id)
          get :create, user_id: user2.id
          expect(controller.current_user.id).to eq(user2.id)
        end
      end

      describe "#destroy" do
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
