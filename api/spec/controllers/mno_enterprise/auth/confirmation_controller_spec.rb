require 'rails_helper'

module MnoEnterprise
  describe Auth::ConfirmationsController, type: :controller do
    routes { MnoEnterprise::Engine.routes }

    before { @request.env['devise.mapping'] = Devise.mappings[:user] }

    let(:unconfirmed_user) { build(:user, :unconfirmed, organizations: []) }
    let(:confirmed_user) { build(:user, organizations: []) }


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
          let!(:api_stubs) do
            user.unconfirmed_email = email
            stub_api_v2(:get, '/orga_invites', [], [], {filter: {user_email: user.email}})
          end
          it 'sign in the user' do
            subject
            expect(controller.current_user).to eq(user)
          end

          it 'redirects to the dashboard' do
            expect(subject).to redirect_to(controller.signed_in_root_path(user))
          end
        end
        # TODO: Understand why calling confim on already confirmed user should not sign the user...
        xit 'does not sign in the user' do
          subject
          expect(controller.current_user).to be_nil
        end
        # TODO: Understand why calling confim on already confirmed user should return an error
        xit 'returns an error' do
          expect(subject).to render_template('new')
        end
      end
    end

    describe 'PATCH #finalize' do
      let(:user_params) { {confirmation_token: user.confirmation_token, password: 'test', name: 'test'} }
      subject { post :finalize, user: user_params }

      before do
        allow(MnoEnterprise::User).to receive(:find_for_confirmation) { user }
        stub_api_v2(:get, '/orga_invites', [], [], {filter: {user_email: user.email}})

        api_stub_for(put: "/users/#{user.id}", response: from_api(user))
        stub_audit_events
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
