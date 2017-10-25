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
        subject { get :create, user_id: user2.id }
        it do
          expect(controller.current_user.id).to eq(user.id)
          subject
          expect(controller.current_user.id).to eq(user2.id)
        end

        context 'with an organisation id in parameters' do
          subject { get :create, user_id: user.id, dhbRefId: 10 }

          it { is_expected.to redirect_to('/dashboard/#!?dhbRefId=10') }
        end

        context 'when the user is a staff member' do
          let(:user2) { build(:user, admin_role: 'staff') }
          it do
            subject
            expect(controller).to set_flash[:notice].to('User is a staff member')
          end
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
