require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::Admin::OrganizationsController, type: :controller do
    include MnoEnterprise::TestingSupport::OrganizationsSharedHelpers
    include MnoEnterprise::TestingSupport::SharedExamples::JpiV1Admin
    include MnoEnterprise::TestingSupport::SharedExamples::OrganizationSharedExamples

    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env["HTTP_ACCEPT"] = 'application/json' }

    #===============================================
    # Assignments
    #===============================================
    let!(:organization) { build(:organization, orga_invites: [], users: [], orga_relations: [], main_address: main_address) }
    let(:role) { 'Admin' }
    let!(:user) {
      u = build(:user, :admin, organizations: [organization], orga_relations: [orga_relation], dashboards: [])
      orga_relation.user_id = u.id
      u
    }
    let!(:orga_relation) { build(:orga_relation, organization_id: organization.id, role: role) }
    let!(:organization_stub) { stub_api_v2(:get, "/organizations/#{organization.id}", organization, %i(users orga_invites orga_relations credit_card invoices main_address)) }
    # Stub user and user call
    let!(:current_user_stub) { stub_user(user) }

    let!(:arrears_situation) { build(:arrears_situation) }
    let!(:app) { build(:app) }
    let!(:app_instance) { build(:app_instance, organization: organization) }
    let!(:main_address) { build(:main_address) }

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
            :geo_city, :geo_tz, :geo_currency, :metadata, :industry, :size, :financial_year_end_month, :credit_card,
            :financial_metrics, :created_at, :external_id, :belong_to_sub_tenant, :belong_to_account_manager, :demo_account
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
      let(:includes) { [:app_instances, :'app_instances.app', :users, :'users.user_access_requests', :orga_relations, :invoices, :credit_card, :orga_invites, :'orga_invites.user', :main_address] }
      let(:app_instance_includes) { [:app] }
      let(:app_instance_filter) do
        {
          fulfilled_only: true,
          'owner.id': organization.id,
          'status.in': MnoEnterprise::AppInstance::ACTIVE_STATUSES.join(',')
        }
      end

      let(:selected_fields) do
        {
          organizations: [:name, :uid, :soa_enabled, :created_at, :account_frozen, :financial_metrics,
                          :billing_currency, :external_id, :app_instances, :orga_invites, :users,
                          :orga_relations, :invoices, :credit_card, :demo_account, :main_address].join(',')
        }
      end

      let(:expected_params) { { _metadata: { act_as_manager: user.id }, fields: selected_fields } }

      before { allow(app_instance).to receive(:app).and_return(app) }
      before { allow(organization).to receive(:app_instances).and_return([app_instance]) }
      before { allow(organization).to receive(:invoices).and_return([]) }
      before { stub_api_v2(:get, "/organizations/#{organization.id}", organization, includes, expected_params) }
      before { stub_api_v2(:get, "/app_instances", app_instance, app_instance_includes, { filter: app_instance_filter }) }
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
      let(:main_address_attributes) { {street: "404 5th Ave", city: "New York", state_code: "NY", postal_code: "10018", country_code: "US" } }
      let(:params) { {'name' => organization.name, 'main_address_attributes' => main_address_attributes} }
      let(:includes) { [:app_instances, :'app_instances.app', :users, :'users.user_access_requests', :orga_relations, :invoices, :credit_card, :orga_invites, :'orga_invites.user', :main_address] }

      subject { post :create, organization: params }

      before { stub_api_v2(:post, '/organizations', organization) }
      before { allow(app_instance).to receive(:app).and_return(app) }
      before { allow(organization).to receive(:app_instances).and_return([app_instance]) }
      before { allow(organization).to receive(:invoices).and_return([]) }
      # Reloading organization
      before { stub_api_v2(:get, "/organizations/#{organization.id}", organization, includes) }

      describe 'creation' do
        context 'success' do
          before { subject }

          it 'creates the organization' do
            expect(assigns(:organization).name).to eq(organization.name)
            expect(assigns(:organization).main_address).to eq(organization.main_address)
          end
        end
      end

      describe '#update_app_list' do
        let(:app_nids) { ['xero', app_instance.app.nid] }
        let(:params) { attributes_for(:organization).merge(app_nids: app_nids) }

        before { expect_any_instance_of(Organization).to receive(:provision_app_instance!) }
        before { subject }

        it { expect(assigns(:organization).app_instances.map(&:id)).to eq(organization.app_instances.map(&:id)) }
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
        before { stub_api_v2(:get, "/organizations/#{organization.id}", organization, [:orga_relations]) }
        before { stub_api_v2(:get, '/users', nil, [:orga_relations], { filter: { email: params[:email] }, page: { number: 1, size: 1 } }) }
        before { stub_api_v2(:get, "/orga_invites/#{orga_invite.id}", orga_invite, [:user]) }
        before { expect(MnoEnterprise::OrgaInvite).to receive(:create).and_return(orga_invite) }
        before { subject }
        it { expect(data['user']['id']).to eq(invited_user.id) }
      end
    end

    describe 'update and remove member' do
      it_behaves_like 'organization update and remove'
    end

    describe 'PUT #freeze_account' do
      let(:includes) { [:app_instances, :'app_instances.app', :users, :'users.user_access_requests', :orga_relations, :invoices, :credit_card, :orga_invites, :'orga_invites.user', :main_address] }

      subject { put :freeze_account, id: organization.id }

      before { allow(app_instance).to receive(:app).and_return(app) }
      before { allow(organization).to receive(:app_instances).and_return([app_instance]) }
      before { allow(organization).to receive(:invoices).and_return([]) }

      before { stub_api_v2(:get, "/organizations/#{organization.id}", organization, includes, { _metadata: { act_as_manager: user.id } }) }
      before { stub_api_v2(:patch, "/organizations/#{organization.id}/freeze", organization) }

      before { subject }

      it { expect(response).to be_success }
    end

    describe 'PUT #unfreeze' do
      let(:includes) { [:app_instances, :'app_instances.app', :users, :'users.user_access_requests', :orga_relations, :invoices, :credit_card, :orga_invites, :'orga_invites.user', :main_address] }

      subject { put :unfreeze, id: organization.id }

      before { allow(app_instance).to receive(:app).and_return(app) }
      before { allow(organization).to receive(:app_instances).and_return([app_instance]) }
      before { allow(organization).to receive(:invoices).and_return([]) }

      before { stub_api_v2(:get, "/organizations/#{organization.id}", organization, includes, { _metadata: { act_as_manager: user.id } }) }
      before { stub_api_v2(:patch, "/organizations/#{organization.id}/unfreeze", organization) }

      before { subject }

      it { expect(response).to be_success }
    end

    describe 'GET #download_batch_example' do

      subject { get :download_batch_example, file: file }

      context 'successful download' do
        let(:path) { MnoEnterprise::Api::Engine.root.join('app/assets/batch-example.csv') }
        let(:file) { File.read(path) }

        it { expect(subject.status).to eq 200 }
        it { expect(subject.body).to eq file }
      end
    end

    describe 'POST #batch_upload' do
      subject { post :batch_import, file: file }

      context 'invalid file' do
        let(:file) { fixture_file_upload('batch-example-bad.csv', 'text/csv') }
        before { subject }
        it { expect(response.status).to eq 400 }

        let(:expected_errors) {
          [
            "Row: 1, Invalid Country code 'AnyCountry'. It must follow ISO 3166 Standard two-letter country codes.",
            "Row: 1, Invalid email: 'notanemail'",
            "Row: 2, Missing value for column: 'company_name'.",
            "Row: 2, Invalid Country code 'UK'. It must follow ISO 3166 Standard two-letter country codes."
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
            stub_api_v2(:post, '/addresses'),
            stub_api_v2(:patch, "/organizations/#{organization1.id}", organization1),

            stub_api_v2(:get, '/users', [], [], { filter: { email: 'john.doe@example.com' }, page: { number: 1, size: 1 } }),
            stub_api_v2(:get, '/users', [user1], [], { filter: { email: 'jane.doe@example.com' }, page: { number: 1, size: 1 } }),

            stub_api_v2(:post, '/users', user2),
            stub_api_v2(:patch, "/users/#{user1.id}", user1),

            stub_api_v2(:get, "/users/#{user1.id}", user1, [:sub_tenant]),
            stub_api_v2(:get, "/users/#{user2.id}", user2, [:sub_tenant]),

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

        let(:file) { file = fixture_file_upload('batch-example.csv', 'text/csv') }

        before { sign_in user }
        before { subject }
        it { expect(response).to be_success }
        it 'does the requests' do
          stubs.each { |stub| expect(stub).to have_been_requested.at_least_once }
        end
        it 'generates the report' do
          import_report = assigns(:import_report)
          expect(import_report).not_to be_nil
          organizations = import_report[:organizations]
          expect(organizations[:updated].length).to be 1
          expect(organizations[:updated].first.id).to eq organization1.id
          expect(organizations[:added].length).to be 1
          expect(organizations[:added].first.id).to eq organization2.id
          users = import_report[:users]
          expect(users[:updated].length).to be 1
          expect(users[:updated].first.id).to eq user1.id
          expect(users[:added].length).to be 1
          expect(users[:added].first.id).to eq user2.id
        end

      end
    end
  end
end
