require 'rails_helper'

module MnoEnterprise
  module Auth

    describe ConfirmationsController, type: :controller do
      render_views
      routes { MnoEnterprise::Engine.routes }
      before { request.env["devise.mapping"] = Devise.mappings[:user] } #bypass devise router


      let(:user) { build(:user) }
      let(:new_email) { user.email + '.au' }
      let(:email_params) {{ filter: { email: user.email }, limit: 1 }}
      let(:new_email_params) {{ filter: { email: new_email }, limit: 1 }}

      before { allow(MnoEnterprise::User).to receive(:find_for_confirmation).with(any_args).and_return(user) }

      before { api_stub_for(get: "/users", params: email_params, respond_with: []) }
      before { api_stub_for(get: "/users", respond_with: [user]) }
      before { api_stub_for(get: "/org_invites", respond_with: []) }
      before { api_stub_for(get: "/users/#{user.id}/organizations", respond_with: []) }

      before { api_stub_for(put: "/users/#{user.id}", respond_with: user) }


      describe 'GET #show' do
        subject { get :show, confirmation_token: user.confirmation_token }

        describe 'confirmed user confirming new email address' do
          before { user.unconfirmed_email = new_email }

          before { subject }
          it { expect(user.email).to eq(new_email) }
          it { expect(response).to redirect_to(root_path) }
        end

        describe 'unconfirmed user' do

          let(:tos_accepted_at) { nil }
          before { user.meta_data[:tos_accepted_at] = tos_accepted_at }

          before { user.confirmed_at = nil }
          before { subject }
          it { expect(response.code).to eq('200') }
          it { expect(assigns(:confirmation_token)).to eq(user.confirmation_token) }

          context 'when TOS accepted' do
            let(:tos_accepted_at) { 1.days.ago }
            it 'does not show the TOS checkbox' do
              expect(response.body).not_to include('id="tos"')
            end
          end

          context 'when TOS not accepted' do
            it 'shows the TOS checkbox' do
              expect(response.body).to include('id="tos"')
            end
          end
        end
      end

      describe 'PATCH #finalize' do
        let(:previous_url) { nil }
        let(:user_params) {{ name: 'Robert', surname: 'Jack', password: 'somepassword', confirmation_token: user.confirmation_token }}
        subject { patch :finalize, user: user_params }

        before { session[:previous_url] = previous_url }

        describe 'confirmed user' do
          before { subject }
          it { expect(user.name).to_not eq(user_params[:name]) }
          it { expect(response).to redirect_to(root_path) }
        end

        describe 'unconfirmed user' do
          before { user.confirmed_at = nil }
          before { subject }
          it { expect(user.name).to eq(user_params[:name]) }
          it { expect(user.surname).to eq(user_params[:surname]) }
          it { expect(user.password).to eq(user_params[:password]) }
          it { expect(response).to redirect_to(MnoEnterprise.router.dashboard_path) }

          describe 'with previous url' do
            let(:previous_url) { "/some/redirection" }
            it { expect(response).to redirect_to(previous_url) }
          end
        end

        describe 'invalid confirmation token ' do
          let(:user_with_errors) { obj = MnoEnterprise::User.new; obj.errors[:base] << "Invalid confirmation token"; obj }
          before { allow(MnoEnterprise::User).to receive(:find_for_confirmation).with(any_args).and_return(user_with_errors) }
          subject! { patch :finalize, user: user_params.merge(confirmation_token: 'invalid') }
          it { expect(user.name).to_not eq(user_params[:name]) }
          it { expect(response.code).to eq('200') }
        end
      end
    end

  end
end
