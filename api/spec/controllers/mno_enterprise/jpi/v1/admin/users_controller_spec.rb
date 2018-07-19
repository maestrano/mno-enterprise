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
    # This is the current user, it must be named user so that the shared examples can work.
    let(:user) { build(:user, current_user_admin_role) }
    let(:current_user_admin_role) { :admin }
    let!(:current_user_stub) { stub_user(user) }

    # This is the user searched for, i.e. what is returned from a show request.
    let(:user_searched) { build(:user, admin_role) }
    let(:admin_role) { :admin }

    #===============================================
    # Specs
    #===============================================
    before { sign_in user }

    describe 'GET #index' do
      subject { get :index }

      let(:data) { JSON.parse(response.body) }

      before { stub_api_v2(:get, "/users", [user_searched], [:user_access_requests, :sub_tenant], { _locale: :en, _metadata: { act_as_manager: user.id } }) }

      it_behaves_like 'a jpi v1 admin action'
      it_behaves_like 'an unauthorized route for support users'
      it { subject; expect(data['users'].first['id']).to eq(user_searched.id) }
    end

    describe 'GET #show' do
      subject { get :show, id: user_searched.id }

      let(:data) { JSON.parse(response.body) }
      let(:included) { [:orga_relations, :organizations, :user_access_requests, :sub_tenant] }

      before { stub_api_v2(:get, "/users/#{user_searched.id}", user_searched, included, { _metadata: { act_as_manager: user.id } }) }

      it_behaves_like 'a jpi v1 admin action'

      it 'finds the correct user' do
        expect(controller).not_to receive(:authorize!)
        subject
        expect(data['user']['id']).to eq(user_searched.id)
      end

      context 'with a suport user' do
        let(:current_user_admin_role) { :support }
        it 'authorizes the user' do
          expect(controller).to receive(:authorize!)
          subject
        end
      end
    end

    describe 'POST #create' do
      let(:confirmation_token) { '1e243fa1180e32f3ec66a648835d1fbca7912223a487eac36be22b095a01b5a5' }
      before {
        Devise.token_generator
        stub_api_v2(:get, '/users', [], [], { filter: { email: 'test@toto.com' }, page: { number: 1, size: 1 } })
        stub_api_v2(:get, '/users', [], [], { filter: { confirmation_token: confirmation_token } })
        stub_api_v2(:get, "/users/#{user_searched.id}", user_searched, [:sub_tenant])
        stub_api_v2(:patch, "/users/#{user_searched.id}", user_searched)
        allow_any_instance_of(Devise::TokenGenerator).to receive(:digest).and_return(confirmation_token)
        allow_any_instance_of(Devise::TokenGenerator).to receive(:generate).and_return(confirmation_token)
      }
      subject { post :create, user: params }

      let(:data) { JSON.parse(response.body) }
      let(:params) { { 'name' => 'Foo', 'email' => 'test@toto.com' } }
      let(:expected_params) { params.merge('sub_tenant_id' => nil) }
      let!(:stub) { stub_api_v2(:post, '/users', user_searched) }

      it_behaves_like 'a jpi v1 admin action'
      it_behaves_like 'an unauthorized route for support users'
      it 'creates the appropriate user' do
        subject
        expect(stub).to have_been_requested
        expect(data['user']['id']).to eq(user_searched.id)
      end

      context 'with a staff user' do
        let(:params) { { 'name' => 'Foo', 'email' => 'test@toto.com', 'admin_role' => MnoEnterprise::User::STAFF_ROLE } }

        let!(:stub) do
          args = {'orga_on_create' => true, 'company' => 'Demo Company', 'demo_account' => 'Staff demo company'}
          stub_request(:post, 'https://api-enterprise.maestrano.test/api/mnoe/v2/users?_locale=en')
            .with(body: {"data" => hash_including("attributes" => hash_including(args))})
            .to_return(status: 200, body: from_apiv2(user_searched, []).to_json, headers: MnoEnterpriseApiTestHelper::JSON_API_RESULT_HEADERS)
        end

        it { subject; expect(stub).to have_been_requested }
      end
    end

    describe 'PUT #update' do
      subject { put :update, id: user_searched.id, user: params }

      let(:data) { JSON.parse(subject.body) }
      let(:params) { { 'name' => 'Foo' } }
      let(:expected_params) { params.merge('sub_tenant_id' => nil) }

      before { stub_api_v2(:get, "/users/#{user_searched.id}", user_searched, [], { _metadata: { act_as_manager: user.id } }) }
      before { stub_api_v2(:get, "/users/#{user_searched.id}", user_searched, [:sub_tenant]) }
      before { stub_api_v2(:patch, "/users/#{user_searched.id}") }

      it_behaves_like 'an unauthorized route for support users'
      it_behaves_like 'a jpi v1 admin action'

      it 'properly saves the user' do
        expect_any_instance_of(MnoEnterprise::User).to receive(:save!)
        subject
        expect(data['user']['id']).to eq(user_searched.id)
      end

      context 'when changing a staff to admin' do
        let(:user_searched) { build(:user, admin_role: MnoEnterprise::User::STAFF_ROLE) }
        let(:params) { { 'name' => 'Foo', 'admin_role' => MnoEnterprise::User::ADMIN_ROLE } }
        before { expect_any_instance_of(MnoEnterprise::User).to receive(:clear_clients!) }

        # Dummy test to trigger the above expectation
        it { subject; expect(data['user']['id']).to eq(user_searched.id) }
      end
    end

    describe 'PATCH #update_clients' do
      subject { put :update_clients, id: user_searched.id, user: params }

      let(:data) { JSON.parse(response.body) }
      let(:params) { { add: ['id'] } }

      before { stub_api_v2(:get, "/users/#{user_searched.id}", user_searched, [], { _metadata: { act_as_manager: user.id } }) }
      before { stub_api_v2(:get, "/users/#{user_searched.id}", user_searched, [:sub_tenant]) }
      let!(:stub) { stub_api_v2(:patch, "/users/#{user_searched.id}/update_clients", user_searched) }

      it_behaves_like 'a jpi v1 admin action'
      it_behaves_like 'an unauthorized route for support users'

      it 'updates the clients' do
        subject
        expect(data['user']['id']).to eq(user_searched.id)
        expect(stub).to have_been_requested
      end
    end

    describe 'DELETE #destroy' do
      subject { delete :destroy, id: user_searched.id }

      let(:data) { JSON.parse(response.body) }

      before { stub_api_v2(:get, "/users/#{user_searched.id}", user_searched, [], { _metadata: { act_as_manager: user.id } }) }
      before { stub_api_v2(:delete, "/users/#{user_searched.id}") }

      it_behaves_like 'a jpi v1 admin action'
      it_behaves_like 'an unauthorized route for support users'

      it 'makes a call to delete the organization' do
        expect_any_instance_of(MnoEnterprise::User).to receive(:destroy)
        expect(subject).to be_success
      end
    end

    describe 'POST #signup_email' do
      subject { post :signup_email, user: { email: email } }

      let(:email) { 'test@test.com' }
      let(:mailer) { double('mailer') }

      it_behaves_like 'a jpi v1 admin action'
      it_behaves_like 'an unauthorized route for support users'

      it 'makes the appropriate request for the signup email' do
        expect(MnoEnterprise::SystemNotificationMailer).to receive(:registration_instructions).with(email).and_return(mailer)
        expect(mailer).to receive(:deliver_later)
        expect(subject).to be_success
      end
    end

    describe 'POST #login_with_org_external_id' do
      subject { post :login_with_org_external_id, id: user.id, organization_external_id: organization_external_id }

      before do
        Settings.merge!(admin_panel: {support: {enabled: true}})
        Rails.application.reload_routes!
      end

      let(:organization_external_id) { 1 }

      context 'with support settings enabled' do
        let(:organizations) { [organization] }
        let(:organization) { build(:organization, external_id: 1) }

        context 'when the current user is not a support user' do
          it { is_expected.not_to be_success }
        end

        context 'when the user is a support user' do
          let(:current_user_admin_role) { :support }
          before { stub_api_v2(:get, '/organizations', organizations, [], { filter: { external_id: 1 }, page: { number: 1, size: 1 } }) }

          it { is_expected.to be_success }
          it 'sets the session of support_org_id' do
            expect(cookies[:support_org_id]).to be_nil
            expect(session[:support_org_id]).to be_nil
            subject
            expect(cookies[:support_org_id]).to eq(organization.id)
            expect(session[:support_org_id]).to eq(organization.id)
          end

          context 'when mnohub cannot find the organization' do
            let(:organizations) { [] }
            it { is_expected.not_to be_success }
          end
        end
      end
    end

    describe 'DELETE #logout_support' do
      subject { delete :logout_support, { id: user.id }, { support_org_external_id: organization.external_id } }

      before do
        Settings.merge!(admin_panel: {support: {enabled: true}})
        Rails.application.reload_routes!
      end
      let(:organization) { build(:organization, external_id: 1) }

      context 'with support settings enabled' do
        let(:organization) { build(:organization) }
        let(:user) { build(:user, admin_role: admin_role) }
        let(:admin_role) { MnoEnterprise::User::SUPPORT_ROLE }

        context 'when the current user is not a support user' do
          let(:admin_role) { MnoEnterprise::User::ADMIN_ROLE }
          it { is_expected.not_to be_success }
        end

        context 'when the user is a support user' do
          it { is_expected.to be_success }
          it 'sets the session of support_org_id' do
            subject
            expect(cookies[:support_org_id]).to be_nil
            expect(session[:support_org_external_id]).to be_nil
          end
        end
      end
    end
  end
end
