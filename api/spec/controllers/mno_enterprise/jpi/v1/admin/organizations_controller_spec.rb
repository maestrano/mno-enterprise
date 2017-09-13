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
    let!(:current_user_stub) { stub_api_v2(:get, "/users/#{user.id}", user, %i(deletion_requests organizations orga_relations dashboards)) }

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
        before { stub_api_v2(:get, "/users", invited_user, [:orga_relations], { filter: { email: params[:email] }, page: { number: 1, size: 1 } }) }
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
        before { stub_api_v2(:get, "/users", nil, [:orga_relations], { filter: { email: params[:email] }, page: { number: 1, size: 1 } }) }
        before { stub_api_v2(:get, "/orga_invites/#{orga_invite.id}", orga_invite, [:user]) }
        before { expect(MnoEnterprise::OrgaInvite).to receive(:create).and_return(orga_invite) }
        before { subject }
        it { expect(data['user']['id']).to eq(invited_user.id) }
      end
    end
  end
end
