require 'rails_helper'

# TODO: Monkey Patch while waiting for PR to be merged
# https://github.com/bblimke/webmock/pull/734
module WebMock
  class BodyPattern
    BODY_FORMATS.merge!('application/vnd.api+json' => :json)
  end
end

module MnoEnterprise
  describe Jpi::V1::Admin::UsersController, type: :controller do
    include MnoEnterprise::TestingSupport::SharedExamples::JpiV1Admin

    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env["HTTP_ACCEPT"] = 'application/json' }
    before { I18n.default_locale = :en }

    #===============================================
    # Assignments
    #===============================================
    let(:current_user) { build(:user, :admin) }
    let!(:current_user_stub) { stub_user(current_user) }

    # Stub user and user call
    let(:user) { build(:user) }

    #===============================================
    # Specs
    #===============================================
    before { sign_in current_user }

    describe 'GET #index' do
      subject { get :index }

      let(:data) { JSON.parse(response.body) }

      before { stub_api_v2(:get, "/users", [user], [:user_access_requests, :sub_tenant], { _locale: :en, _metadata: { act_as_manager: current_user.id } }) }
      before { subject }

      it { expect(data['users'].first['id']).to eq(user.id) }
    end

    describe 'GET #show' do
      subject { get :show, id: user.id }

      let(:data) { JSON.parse(response.body) }
      let(:included) { [:orga_relations, :organizations, :user_access_requests, :sub_tenant] }

      before { stub_api_v2(:get, "/users/#{user.id}", user, included, { _metadata: { act_as_manager: current_user.id } }) }
      before { subject }

      it { expect(data['user']['id']).to eq(user.id) }
    end

    describe 'POST #create' do
      let(:confirmation_token) { '1e243fa1180e32f3ec66a648835d1fbca7912223a487eac36be22b095a01b5a5' }
      before {
        Devise.token_generator
        stub_api_v2(:get, '/users', [], [], { filter: { email: 'test@toto.com' }, page: { number: 1, size: 1 } })
        stub_api_v2(:get, '/users', [], [], { filter: { confirmation_token: confirmation_token } })
        stub_api_v2(:get, "/users/#{user.id}", user, [:sub_tenant])
        stub_api_v2(:patch, "/users/#{user.id}", user)
        allow_any_instance_of(Devise::TokenGenerator).to receive(:digest).and_return(confirmation_token)
        allow_any_instance_of(Devise::TokenGenerator).to receive(:generate).and_return(confirmation_token)
      }
      subject { post :create, user: params }

      let(:data) { JSON.parse(response.body) }
      let(:params) { { 'name' => 'Foo', 'email' => 'test@toto.com' } }
      let(:expected_params) { params.merge('sub_tenant_id' => nil) }
      let!(:stub) { stub_api_v2(:post, '/users', user) }

      before { subject }

      it { expect(data['user']['id']).to eq(user.id) }
      it { expect(stub).to have_been_requested }

      context 'with a staff user' do
        let(:params) { { 'name' => 'Foo', 'email' => 'test@toto.com', 'admin_role' => 'staff' } }

        let!(:stub) do
          args = {'orga_on_create' => true, 'company' => 'Demo Company', 'demo_account' => 'Staff demo company'}
          stub_request(:post, 'https://api-enterprise.maestrano.test/api/mnoe/v2/users?_locale=en')
            .with(body: {"data" => hash_including("attributes" => hash_including(args))})
            .to_return(status: 200, body: from_apiv2(user, []).to_json, headers: MnoEnterpriseApiTestHelper::JSON_API_RESULT_HEADERS)
        end

        before { subject }

        it { expect(stub).to have_been_requested }
      end
    end

    describe 'PUT #update' do
      subject { put :update, id: user.id, user: params }

      let(:data) { JSON.parse(subject.body) }
      let(:params) { { 'name' => 'Foo' } }
      let(:expected_params) { params.merge('sub_tenant_id' => nil) }

      before { expect_any_instance_of(MnoEnterprise::User).to receive(:save!) }
      before { stub_api_v2(:get, "/users/#{user.id}", user, [], { _metadata: { act_as_manager: current_user.id } }) }
      before { stub_api_v2(:get, "/users/#{user.id}", user, [:sub_tenant]) }

      it { expect(data['user']['id']).to eq(user.id) }

      context 'when changing a staff to admin' do
        let(:user) { build(:user, admin_role: 'staff') }
        let(:params) { { 'name' => 'Foo', 'admin_role' => 'admin' } }
        before { expect_any_instance_of(MnoEnterprise::User).to receive(:clear_clients!) }

        # Dummy test to trigger the above expectation
        it { expect(data['user']['id']).to eq(user.id) }
      end
    end

    describe 'PATCH #update_clients' do
      subject { put :update_clients, id: user.id, user: params }

      let(:data) { JSON.parse(response.body) }
      let(:params) { { add: ['id'] } }

      before { stub_api_v2(:get, "/users/#{user.id}", user, [], { _metadata: { act_as_manager: current_user.id } }) }
      before { stub_api_v2(:get, "/users/#{user.id}", user, [:sub_tenant]) }
      let!(:stub) { stub_api_v2(:patch, "/users/#{user.id}/update_clients", user) }
      before { subject }
      it { expect(data['user']['id']).to eq(user.id) }
      it { expect(stub).to have_been_requested }
    end

    describe 'DELETE #destroy' do
      subject { delete :destroy, id: user.id }

      let(:data) { JSON.parse(response.body) }

      before { expect_any_instance_of(MnoEnterprise::User).to receive(:destroy) }
      before { stub_api_v2(:get, "/users/#{user.id}", user, [], { _metadata: { act_as_manager: current_user.id } }) }

      it { is_expected.to be_success }
    end

    describe 'POST #signup_email' do
      subject { post :signup_email, user: { email: email } }

      let(:email) { 'test@test.com' }
      let(:mailer) { double('mailer') }

      before { expect(MnoEnterprise::SystemNotificationMailer).to receive(:registration_instructions).with(email).and_return(mailer) }
      before { expect(mailer).to receive(:deliver_later) }

      it { is_expected.to be_success }
    end

    describe 'POST #login_with_org_external_id' do
      subject { post :login_with_org_external_id, id: current_user.id, organization_external_id: organization_external_id }

      before { Settings.merge!(admin_panel: {support: {enabled: enabled}}) }
      let(:enabled) { true }
      let(:organization_external_id) { 1 }

      context 'with support settings disabled' do
        let(:enabled) { false }
        it { is_expected.not_to be_success }
      end

      context 'with support settings enabled' do
        let(:current_user) { build(:user, admin_role: admin_role) }
        let(:organizations) { [organization] }
        let(:organization) { build(:organization, external_id: 1) }
        let(:admin_role) { 'support' }

        context 'when the current user is not a support user' do
          let(:admin_role) { 'admin' }
          it { is_expected.not_to be_success }
        end

        context 'when the user is a support user' do
          before { stub_api_v2(:get, '/organizations', organizations, [], { filter: { external_id: 1 }, page: { number: 1, size: 1 } }) }

          it { is_expected.to be_success }
          it 'sets the session of support_org_id' do
            expect(session[:support_org_external_id]).to be_nil
            subject
            expect(session[:support_org_external_id]).to eq(organization.external_id)
          end

          context 'when mnohub cannot find the organization' do
            let(:organizations) { [] }
            it { is_expected.not_to be_success }
          end
        end
      end
    end

    describe 'DELETE #logout_support' do
      subject { delete :logout_support, { id: current_user.id }, { support_org_external_id: organization.external_id } }

      before { Settings.merge!(admin_panel: {support: {enabled: enabled}}) }
      let(:enabled) { true }
      let(:organization) { build(:organization, external_id: 1) }

      context 'with support settings disabled' do
        let(:enabled) { false }
        it { is_expected.not_to be_success }
      end

      context 'with support settings enabled' do
        let(:organization) { build(:organization) }
        let(:current_user) { build(:user, admin_role: admin_role) }
        let(:admin_role) { 'support' }

        context 'when the current user is not a support user' do
          let(:admin_role) { 'admin' }
          it { is_expected.not_to be_success }
        end

        context 'when the user is a support user' do
          it { is_expected.to be_success }
          it 'sets the session of support_org_id' do
            subject
            expect(session[:support_org_id]).to be_nil
          end
        end
      end
    end
  end
end
