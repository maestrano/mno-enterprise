require 'rails_helper'

module MnoEnterprise
  RSpec.describe 'Remote Authentication', type: :request do

    let(:user) { build(:user) }
    before {
      stub_api_v2(:get, "/users/#{user.id}", user, %i(deletion_requests organizations orga_relations dashboards))
      stub_api_v2(:patch, "/users/#{user.id}", user)
    }
    let!(:authentication_stub){ stub_api_v2(:post, "/users/authenticate", user)}

    before { stub_audit_events }

    describe 'login' do
      subject { post '/mnoe/auth/users/sign_in', user: {email: user.email, password: 'securepassword'} }

      describe 'success' do
        before { subject }

        it 'logs the user in' do
          expect(controller).to be_user_signed_in
          expect(controller.current_user.id).to eq(user.id)
          expect(controller.current_user.name).to eq(user.name)
        end
      end

      describe 'failure' do
        let!(:authentication_stub){ stub_api_v2_error(:post, "/users/authenticate", 404, 'Could not find')}

        before { subject }

        it 'does logs the user in' do
          expect(controller).to_not be_user_signed_in
          expect(controller.current_user).to be_nil
        end
      end
    end
  end
end
