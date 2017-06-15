require 'rails_helper'

module MnoEnterprise
  module Auth

    describe ConfirmationsController, type: :controller do
      render_views
      routes { MnoEnterprise::Engine.routes }
      before { request.env["devise.mapping"] = Devise.mappings[:user] } #bypass devise router

      let(:user) {
        u = build(:user)
        u.mark_as_persisted!
        u
      }
      let(:new_email) { user.email + '.au' }

      before { allow(MnoEnterprise::User).to receive(:find_for_confirmation).with(any_args).and_return(user) }

      before {
        stub_api_v2(:get, '/users', [user])
        stub_api_v2(:get, '/orga_invites', [], [], {filter: {user_email: user.email}})
        stub_audit_events
        stub_api_v2(:get, '/users', [], [], {filter: {email: new_email}, page:{number: 1, size: 1}})
      }


      describe 'GET #show' do
        subject { get :show, confirmation_token: user.confirmation_token }

        describe 'confirmed user confirming new email address' do
          before {
            user.unconfirmed_email = new_email
            stub_api_v2(:patch, "/users/#{user.id}", user)
            subject
          }

          it {assert_requested_api_v2(:patch, "/users/#{user.id}", times: 2) }
          it { expect(response).to redirect_to(root_path) }
        end

        describe 'unconfirmed user' do
          before { user.confirmed_at = nil }
          before { subject }
          it { expect(response.code).to eq('200') }
          it { expect(assigns(:confirmation_token)).to eq(user.confirmation_token) }
        end
      end

      describe 'PATCH #finalize' do
        let(:previous_url) { nil }
        let(:user_params) { {name: 'Robert', surname: 'Jack', password: 'somepassword', confirmation_token: user.confirmation_token} }
        subject { patch :finalize, user: user_params }

        before { session[:previous_url] = previous_url }

        describe 'confirmed user' do
          before { subject }
          it { expect(response).to redirect_to(root_path) }
        end

        describe('unconfirmed user') {
          before {
            user.confirmed_at = nil
            stub_api_v2(:patch, "/users/#{user.id}", user)
            subject
          }
          # save is called twice, once for perform_confirmation and just after
          # resource.perform_confirmation(@confirmation_token)
          # resource.save
          # TODO: check if it possible to save only once
          it { assert_requested_api_v2(:patch, "/users/#{user.id}", times: 2) }
          it { expect(response).to redirect_to(MnoEnterprise.router.dashboard_path) }

          describe 'with previous url' do
            let(:previous_url) { '/some/redirection' }
            it { expect(response).to redirect_to(previous_url) }
          end
        }

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
