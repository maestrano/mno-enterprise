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

    # Stub user and user call
    let(:user) { build(:user) }

    #===============================================
    # Specs
    #===============================================
    before { sign_in current_user }

    describe 'GET #index' do
      subject { get :index }

      let(:data) { JSON.parse(response.body) }

      before { stub_api_v2(:get, "/users", [user], [:user_access_requests], { _metadata: { act_as_manager: current_user.id } }) }
      before { subject }

      it { expect(data['users'].first['id']).to eq(user.id) }
    end

    describe 'GET #show' do
      subject { get :show, id: user.id }

      let(:data) { JSON.parse(response.body) }
      let(:included) { [:orga_relations, :organizations, :user_access_requests, :clients] }

      before { allow(user).to receive(:clients).and_return([]) }
      before { stub_api_v2(:get, "/users/#{user.id}", user, included, { _metadata: { act_as_manager: current_user.id } }) }
      before { subject }

      it { expect(data['user']['id']).to eq(user.id) }
    end

    describe 'POST #create' do
      subject { post :create, user: params }

      let(:data) { JSON.parse(response.body) }
      let(:params) { { 'name' => 'Foo' } }
      let(:expected_params) { params.merge('sub_tenant_id' => nil) }

      before { allow(user).to receive(:clients).and_return([]) }
      before { expect(MnoEnterprise::User).to receive(:create).with(hash_including(expected_params)).and_return(user) }
      before { stub_api_v2(:get, "/users/#{user.id}", user, [:clients]) }
      before { subject }

      it { expect(data['user']['id']).to eq(user.id) }
    end

    describe 'PUT #update' do
      subject { put :update, id: user.id, user: params }

      let(:data) { JSON.parse(response.body) }
      let(:params) { { 'name' => 'Foo' } }
      let(:expected_params) { params.merge('sub_tenant_id' => nil) }

      before { allow(user).to receive(:clients).and_return([]) }
      before { expect_any_instance_of(MnoEnterprise::User).to receive(:update).with(expected_params) }
      before { stub_api_v2(:get, "/users/#{user.id}", user, [], { _metadata: { act_as_manager: current_user.id } }) }
      before { stub_api_v2(:get, "/users/#{user.id}", user, [:clients]) }
      before { subject }

      it { expect(data['user']['id']).to eq(user.id) }
    end

    describe 'DELETE #destroy' do
      subject { delete :destroy, id: user.id }

      let(:data) { JSON.parse(response.body) }

      before { allow(user).to receive(:clients).and_return([]) }
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
