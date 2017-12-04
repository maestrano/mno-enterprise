require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::Admin::UsersController, type: :controller do
    include MnoEnterprise::TestingSupport::SharedExamples::JpiV1Admin

    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env["HTTP_ACCEPT"] = 'application/json' }

    #===============================================
    # Assignments
    #===============================================
    let(:current_user) { build(:user, :admin) }
    let!(:current_user_stub) { stub_user(current_user) }

    let(:select_fields) do
      {
        users: Jpi::V1::Admin::UsersController::INCLUDED_FIELDS.join(',')
      }
    end


    # Stub user and user call
    let(:user) { build(:user) }

    #===============================================
    # Specs
    #===============================================
    before { sign_in current_user }

    describe 'GET #index' do
      subject { get :index }

      let(:data) { JSON.parse(response.body) }

      before { stub_api_v2(:get, "/users", [user], [:user_access_requests, :sub_tenant], {fields: select_fields, _metadata: { act_as_manager: current_user.id } }) }
      before { subject }

      it { expect(data['users'].first['id']).to eq(user.id) }
    end

    describe 'GET #show' do
      subject { get :show, id: user.id }

      let(:data) { JSON.parse(response.body) }
      let(:included) { [:orga_relations, :organizations, :user_access_requests, :sub_tenant] }

      before { stub_api_v2(:get, "/users/#{user.id}", user, included, {fields: select_fields, _metadata: { act_as_manager: current_user.id } }) }
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
    end

    describe 'PUT #update' do
      subject { put :update, id: user.id, user: params }

      let(:data) { JSON.parse(response.body) }
      let(:params) { { 'name' => 'Foo' } }
      let(:expected_params) { params.merge('sub_tenant_id' => nil) }

      before { expect_any_instance_of(MnoEnterprise::User).to receive(:save) }
      before { stub_api_v2(:get, "/users/#{user.id}", user, [], { _metadata: { act_as_manager: current_user.id } }) }
      before { stub_api_v2(:get, "/users/#{user.id}", user, [:sub_tenant]) }
      before { subject }

      it { expect(data['user']['id']).to eq(user.id) }
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
  end
end
