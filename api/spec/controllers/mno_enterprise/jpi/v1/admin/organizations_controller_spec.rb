require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::Admin::OrganizationsController, type: :controller do
    include MnoEnterprise::TestingSupport::SharedExamples::JpiV1Admin

    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env["HTTP_ACCEPT"] = 'application/json' }

    #===============================================
    # Assignments
    #===============================================
    let(:user) { build(:user, :admin) }
    let!(:current_user_stub) { stub_user(user) }

    let(:organization) { build(:organization) }
    let(:arrears_situation) { build(:arrears_situation) }
    let(:app) { build(:app) }
    let(:app_instance) { build(:app_instance, organization: organization) }

    #===============================================
    # Specs
    #===============================================
    before { sign_in user }

    describe 'GET #index' do
      subject { get :index }

      let(:data) { JSON.parse(response.body) }
      let(:select_fields) do
        {
          organizations: [
            :uid, :name, :account_frozen, :soa_enabled, :mails, :logo, :latitude, :longitude, :geo_country_code, :geo_state_code,
            :geo_city, :geo_tz, :geo_currency, :metadata, :industry, :size, :financial_year_end_month, :credit_card, :financial_metrics, :created_at
          ].join(',')
        }
      end
      let(:expected_params) { { fields: select_fields, _metadata: { act_as_manager: user.id } } }

      before { stub_api_v2(:get, "/organizations", [organization], [], expected_params) }
      before { subject }

      it { expect(data['organizations'].first['id']).to eq(organization.id) }
    end

    describe 'GET #show' do
      subject { get :show, id: organization.id }

      let(:data) { JSON.parse(response.body) }
      let(:includes) { [:app_instances, :'app_instances.app', :users, :'users.user_access_requests', :orga_relations, :invoices, :credit_card, :orga_invites, :'orga_invites.user'] }
      let(:expected_params) { { _metadata: { act_as_manager: user.id } } }

      before { allow(app_instance).to receive(:app).and_return(app) }
      before { allow(organization).to receive(:app_instances).and_return([app_instance]) }
      before { allow(organization).to receive(:invoices).and_return([]) }
      before { stub_api_v2(:get, "/organizations/#{organization.id}", organization, includes, expected_params) }
      before { subject }

      it { expect(data['organization']['id']).to eq(organization.id) }
    end

    describe 'GET #in_arrears' do
      subject { get :in_arrears }

      let(:data) { JSON.parse(response.body) }

      before { stub_api_v2(:get, "/arrears_situations", [arrears_situation]) }
      before { subject }

      it { expect(data['in_arrears'].first['name']).to eq(arrears_situation.name) }
    end

    describe 'POST #create' do
      subject { post :create, organization: params }
      let(:params) { attributes_for(:organization) }

      let(:data) { JSON.parse(response.body) }
      let(:includes) { [:app_instances, :'app_instances.app', :users, :'users.user_access_requests', :orga_relations, :invoices, :credit_card, :orga_invites, :'orga_invites.user'] }

      before { allow(app_instance).to receive(:app).and_return(app) }
      before { allow(organization).to receive(:app_instances).and_return([app_instance]) }
      before { allow(organization).to receive(:invoices).and_return([]) }
      before { stub_api_v2(:get, "/organizations/#{organization.id}", organization, includes) }
      before { expect(MnoEnterprise::Organization).to receive(:create).with(params.slice(:name, :billing_currency)).and_return(organization) }

      describe 'creation' do
        before { subject }
        it { expect(data['organization']['id']).to eq(organization.id) }
      end

      describe 'app provisioning' do
        let(:params) { attributes_for(:organization).merge(app_nids: ['xero', app_instance.app.nid]) }

        before { expect_any_instance_of(Organization).to receive(:provision_app_instance) }
        before { subject }
        it { expect(data['organization']['id']).to eq(organization.id) }
      end
    end

    describe 'POST #invite_member' do
      subject { post :invite_member, id: organization.id, user: params }

      let(:data) { JSON.parse(response.body) }

      before { stub_api_v2(:get, "/organizations/#{organization.id}", organization, [:orga_relations], { _metadata: { act_as_manager: user.id } }) }

      context 'with existing user' do
        let(:params) { attributes_for(:user) }
        let(:invited_user) { build(:user) }
        let(:orga_invite) { build(:orga_invite) }

        before { allow(orga_invite).to receive(:user).and_return(invited_user) }
        before { stub_api_v2(:get, '/users', invited_user, [:orga_relations], { filter: { email: params[:email] }, page: { number: 1, size: 1 } }) }
        before { stub_api_v2(:get, "/orga_invites/#{orga_invite.id}", orga_invite, [:user]) }
        before { expect(MnoEnterprise::OrgaInvite).to receive(:create).and_return(orga_invite) }
        before { subject }
        it { expect(data['user']['id']).to eq(invited_user.id) }
      end

      context 'with new user' do
        let(:params) { attributes_for(:user) }
        let(:invited_user) { build(:user) }
        let(:orga_invite) { build(:orga_invite) }

        before { allow(invited_user).to receive(:confirmed?).and_return(false) }
        before { allow(controller).to receive(:create_unconfirmed_user).and_return(invited_user) }
        before { allow(orga_invite).to receive(:user).and_return(invited_user) }
        before { stub_api_v2(:get, '/users', nil, [:orga_relations], { filter: { email: params[:email] }, page: { number: 1, size: 1 } }) }
        before { stub_api_v2(:get, "/orga_invites/#{orga_invite.id}", orga_invite, [:user]) }
        before { expect(MnoEnterprise::OrgaInvite).to receive(:create).and_return(orga_invite) }
        before { subject }
        it { expect(data['user']['id']).to eq(invited_user.id) }
      end
    end

    describe 'PUT #freeze' do
      let(:includes) { [:app_instances, :'app_instances.app', :users, :'users.user_access_requests', :orga_relations, :invoices, :credit_card, :orga_invites, :'orga_invites.user'] }

      subject { put :freeze, id: organization.id }

      before { allow(app_instance).to receive(:app).and_return(app) }
      before { allow(organization).to receive(:app_instances).and_return([app_instance]) }
      before { allow(organization).to receive(:invoices).and_return([]) }

      before { stub_api_v2(:get, "/organizations/#{organization.id}", organization, includes, { _metadata: { act_as_manager: user.id } }) }
      before { stub_api_v2(:patch, "/organizations/#{organization.id}/freeze", organization) }

      before { subject }

      it { expect(response).to be_success }
    end

    describe 'PUT #unfreeze' do
      let(:includes) { [:app_instances, :'app_instances.app', :users, :'users.user_access_requests', :orga_relations, :invoices, :credit_card, :orga_invites, :'orga_invites.user'] }

      subject { put :unfreeze, id: organization.id }

      before { allow(app_instance).to receive(:app).and_return(app) }
      before { allow(organization).to receive(:app_instances).and_return([app_instance]) }
      before { allow(organization).to receive(:invoices).and_return([]) }

      before { stub_api_v2(:get, "/organizations/#{organization.id}", organization, includes, { _metadata: { act_as_manager: user.id } }) }
      before { stub_api_v2(:patch, "/organizations/#{organization.id}/unfreeze", organization) }

      before { subject }

      it { expect(response).to be_success }
    end

    describe 'POST #batch_upload' do
      subject { post :batch_import, file: file }

      context 'invalid file' do
        let(:file) { file = fixture_file_upload(File.join(File.dirname(File.expand_path(__FILE__)), '../../../../../fixtures/batch-example-bad.csv'), 'text/csv') }
        before { subject }
        it { expect(response.status).to eq 400 }

        let(:expected_errors) {
          [
            "Row: 1, Invalid email: ''notanemail''",
            "Row: 2, Missing value for column: ''company_name''."
          ]
        }
        it { expect(response.status).to eq 400 }
        it { expect(JSON.parse(response.body)).to eq expected_errors }
      end

      context 'valid file' do
        let(:organization1) { build(:organization) }
        let(:organization2) { build(:organization) }

        let(:user1) { build(:user) }
        let(:user2) { build(:user) }

        let(:orga_relation1) { build(:orga_relation) }
        let(:orga_relation2) { build(:orga_relation) }

        let!(:stubs) {
          [
            stub_api_v2(:get, '/organizations', [], [], { filter: { external_id: 'O1' }, page: { number: 1, size: 1 } }),
            stub_api_v2(:get, '/organizations', [organization1], [], { filter: { external_id: 'O2' }, page: { number: 1, size: 1 } }),

            stub_api_v2(:post, '/organizations', organization2),
            stub_api_v2(:patch, "/organizations/#{organization1.id}", organization1),

            stub_api_v2(:get, '/users', [], [], { filter: { email: 'john.doe@example.com' }, page: { number: 1, size: 1 } }),
            stub_api_v2(:get, '/users', [user1], [], { filter: { email: 'jane.doe@example.com' }, page: { number: 1, size: 1 } }),

            stub_api_v2(:post, '/users', user2),
            stub_api_v2(:patch, "/users/#{user1.id}", user1),

            stub_api_v2(:get, '/orga_relations', [], [], { filter: { user_id: user1.id, organization_id: organization1.id }, page: { number: 1, size: 1 } }),
            stub_api_v2(:get, '/orga_relations', [orga_relation1], [], { filter: { user_id: user2.id, organization_id: organization2.id }, page: { number: 1, size: 1 } }),

            stub_api_v2(:post, '/orga_relations', orga_relation2)
          ]
        }

        before {
          confirmation_token = '1e243fa1180e32f3ec66a648835d1fbca7912223a487eac36be22b095a01b5a5'
          Devise.token_generator
          stub_api_v2(:get, '/users', user, [], { filter: { confirmation_token: confirmation_token } })
          allow_any_instance_of(Devise::TokenGenerator).to receive(:digest).and_return(confirmation_token)
          allow_any_instance_of(Devise::TokenGenerator).to receive(:generate).and_return(confirmation_token)
        }

        let(:file) { file = fixture_file_upload(File.join(File.dirname(File.expand_path(__FILE__)), '../../../../../fixtures/batch-example.csv'), 'text/csv') }

        before { sign_in user }
        before { subject }
        it { expect(response).to be_success }
        it 'does the requests' do
          stubs.each { |stub| expect(stub).to have_been_requested.at_least_once }
        end
      end
    end
  end
end
