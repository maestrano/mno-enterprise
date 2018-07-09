require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::Admin::TeamsController, type: :controller do
    include MnoEnterprise::TestingSupport::SharedExamples::JpiV1Admin

    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env['HTTP_ACCEPT'] = 'application/json' }

    def users_for_team(team)
      team.users.map do |user|
        {
          'id': user.id,
          'name': user.name,
          'surname': user.surname,
          'email': user.email,
          'role': nil
        }
      end
    end

    def apps_for_team(team)
      team.app_instances.map do |app_instance|
        {
          'id': app_instance.id,
          'name': app_instance.name,
          'logo': app_instance.app.logo
        }
      end
    end

    def hash_for_teams(team)
      {
        'teams': [{
          id: team.id,
          name: team.name,
          users: users_for_team(team),
          app_instances: apps_for_team(team)
        }]
      }
    end

    #===============================================
    # Assignments
    #===============================================
    let!(:ability) { stub_ability }
    let!(:user) { build(:user, :admin) }
    let!(:organization) { build(:organization) }
    let!(:team) { build(:team, organization: organization) }
    let!(:role) { MnoEnterprise::User::ADMIN_ROLE }
    let!(:app) { build(:app) }
    let!(:orga_relation) { build(:orga_relation, organization_id: organization.id, role: role, user_id: user.id) }

    before { allow(ability).to receive(:can?).with(any_args).and_return(true) }
    before { sign_in user }

    #===============================================
    # Specs
    #===============================================
    describe 'GET #index' do
      subject { get :index, organization_id: organization.id }

      let!(:current_user_stub) { stub_user(user) }
      let(:includes) { [:app_instances, :users, :'app_instances.app'] }
      let(:data) { JSON.parse(response.body) }
      let(:expected_params) do
        {
          filter: {'organization.id': organization.id},
          fields:{
            teams: 'id,name,app_instances,users',
            app_instances:'id,name,app',
            users: 'id,name,surname,email',
            apps: 'logo'
          }
        }
      end

      before { stub_api_v2(:get, "/teams", team, includes, expected_params) }
      before { stub_api_v2(:get, "/organizations/#{organization.id}", organization, %i(orga_relations)) }
      before { stub_api_v2(:get, "/apps", [app]) }
      before { subject }

      it { expect(response).to be_success }
      it { expect(JSON.parse(response.body)).to eq(JSON.parse(hash_for_teams(team).to_json)) }
      it { expect(data['teams'].first['id']).to eq(team.id) }
    end
  end
end
