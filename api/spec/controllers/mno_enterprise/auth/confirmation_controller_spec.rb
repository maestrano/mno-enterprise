require 'rails_helper'

module MnoEnterprise
  describe Auth::ConfirmationsController, type: :controller do
    routes { MnoEnterprise::Engine.routes }

    before { @request.env['devise.mapping'] = Devise.mappings[:user] }

    let(:unconfirmed_user) { build(:user, :unconfirmed, organizations: [])}
    let(:confirmed_user) { build(:user, organizations: [])}


    describe 'GET #show' do
      subject { get :show, confirmation_token: user.confirmation_token }

      before do
        allow(MnoEnterprise::User).to receive(:find_for_confirmation) { user }
        allow(user).to receive(:save)
      end

      context 'unconfirmed user' do
        let(:user) { unconfirmed_user }

        it 'does not sign in the user' do
          subject
          expect(controller.current_user).to be_nil
        end

        it 'render the template' do
          expect(subject).to render_template('show')
        end
      end

      context 'confirmed user' do
        let(:user) { confirmed_user }

        context 'with a new email' do
          let(:email) { 'unconfirmed@example.com' }

          before do
            user.unconfirmed_email = email

            api_stub_for(get: "/users?filter[email]=#{email}&limit=1", response: from_api(nil))
            api_stub_for(get: "/org_invites?filter[user_email]=#{email}", response: from_api(nil))
          end

          it 'sign in the user' do
            subject
            expect(controller.current_user).to eq(user)
          end

          it 'redirects to the dashboard' do
            expect(subject).to redirect_to(controller.signed_in_root_path(user))
          end
        end

        it 'does not sign in the user' do
          subject
          expect(controller.current_user).to be_nil
        end

        it 'returns an error' do
          expect(subject).to render_template("new")
        end
      end
    end

    describe 'PATCH #finalize' do
      let(:user_params) { {confirmation_token: user.confirmation_token, password: 'test', name: 'test'} }
      subject { post :finalize, user: user_params }

      before do
        allow(MnoEnterprise::User).to receive(:find_for_confirmation) { user }
        api_stub_for(get: "/org_invites?filter[user_email]=#{user.email}", response: from_api(nil))
        api_stub_for(put: "/users/#{user.id}", response: from_api(user))
      end

      context 'unconfirmed user' do
        let(:user) { unconfirmed_user }

        it 'redirects the user to the dashboard' do
          expect(subject).to redirect_to('/dashboard/')
        end

        context 'when password change notifications are enabled' do
          before { user.class.send_password_change_notification = true }

          it 'does not send an email' do
            expect(user).not_to receive(:send_devise_notification)
            subject
          end
        end
      end
    end
  end
end
