require 'rails_helper'

# Specs for Sessions Controller
module MnoEnterprise
  # Auth module
  module Auth
    describe SessionsController, type: :controller do
      routes { MnoEnterprise::Engine.routes }
      # bypass devise router
      before { request.env['devise.mapping'] = Devise.mappings[:user] }
      let(:user) { build(:user) }

      describe '#create' do
        before do
          allow(request.env['warden'])
            .to receive(:authenticate!).and_return(user)
        end

        it 'checks if user requires otp for login' do
          expect(user).to receive(:requires_otp_for_login?)
          post :create
        end

        it "doesn't activates otp when user doesnt' require otp for login" do
          allow(user).to receive(:requires_otp_for_login?) { false }
          expect(user).to_not receive(:activate_otp)
          post :create
        end

        it 'signs in the user' do
          post :create
          expect(controller.current_user).to be user
        end

        context 'when user requires otp for login' do
          before do
            allow(user).to receive(:requires_otp_for_login?) { true }
            allow(user).to receive(:activate_otp)
          end

          it 'signs the user out' do
            expect(controller).to receive(:sign_out).with(user)
            post :create
          end

          it 'activates otp' do
            expect(user).to receive(:activate_otp)
            post :create
          end

          context 'when user has an unconfirmed otp_secret' do
            before do
              user.unconfirmed_otp_secret = 'unconfirmed otp secret'
            end

            it "sets a quick response code into the user's attributes" do
              allow(user).to receive(:activate_otp)
              expect(user).to receive(:set_quick_response_code_in_attributes)
              post :create
            end
          end
        end
      end

      describe 'POST #verify_otp' do
        let(:params) do
          { user_id: '1', otp_attempt: '2' }
        end

        before do
          Settings.authentication.two_factor.admin_enabled = true
          Rails.application.reload_routes!
          allow(MnoEnterprise::User).to receive(:find) { [user] }
        end

        it 'validates otp attempt for specified user' do
          expect(MnoEnterprise::User)
            .to receive(:find).with(id: params[:user_id])
          expect(user)
            .to receive(:validate_and_consume_otp!).with(params[:otp_attempt])
          post :verify_otp, params
        end

        it 'signs in the user when otp attempt is valid' do
          allow(user)
            .to receive(:validate_and_consume_otp!) { true }
          post :verify_otp
          expect(controller.current_user).to be user
        end

        it "doesn't sign in the user when otp attempt is invalid" do
          allow(user)
            .to receive(:validate_and_consume_otp!) { false }
          post :verify_otp
          expect(controller.current_user).to be nil
        end
      end
    end
  end
end
