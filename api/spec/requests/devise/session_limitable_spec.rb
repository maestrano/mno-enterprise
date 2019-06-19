require 'rails_helper'

module MnoEnterprise
  RSpec.describe 'Session Limitation', type: :request do
    include DeviseRequestSpecHelper

    # Initialize this way so the class reload is taken into account (the factory doesnt reload the User class)
    let(:user) do
      MnoEnterprise::User
        .new(attributes_for(:user, email: 'test@maestrano.com', password: 'password', sso_session: 'session-id'))
        .tap { |e| e.clear_changes_information } # Make sure the object is not dirty
    end

    # Reload User class to load proper configuration according to Settings
    def reload_user
      # Removes MnoEnterprise::User from object-space:
      MnoEnterprise.send(:remove_const, :User)
      # Reloads the module (require might also work):
      load '../core/app/models/mno_enterprise/user.rb'
    end

    before do
      Settings.merge!(authentication: { session_limitable: { enabled: true } })
      reload_user

      stub_audit_events
      stub_api_v2(:post, "/users", user)
      login_as(user, scope: warden_scope(:user))
    end

    after do
      Settings.reload!
      reload_user
    end

    describe 'fetch' do
      subject { get '/mnoe/jpi/v1/current_user.json' }
      
      it 'fetches the user' do
        subject
        expect(response).to have_http_status(:success)
      end

      context 'when another session got created in the meantime' do
        # Stub cache write as this doesn't play well with class reloading:
        # > "MnoEnterprise::User can't be referred to"
        before { allow(Rails.cache).to receive(:write).and_return(true) }

        # Stub patch when logging out
        before { stub_api_v2(:patch, "/users/#{user.id}", user) }

        it 'logs the user out and return 401' do
          # 1st request
          get '/mnoe/jpi/v1/current_user.json'

          # Simulate another session being opened by changing the session id
          user.sso_session = 'another-session-id'
          stub_user(user)

          # 2nd request
          get '/mnoe/jpi/v1/current_user.json'
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end
  end
end