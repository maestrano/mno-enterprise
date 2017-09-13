require 'rails_helper'

module MnoEnterprise
  # TODO: Add specs for index, show, destroy, and remove_users
  describe Jpi::V1::TeamsController, type: :controller do
    include MnoEnterprise::TestingSupport::JpiV1TestHelper

    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env['HTTP_ACCEPT'] = 'application/json' }

    def users_for_team(team)
      team.users.map do |user|
        {
          'id' => user.id,
          'name' => user.name,
          'surname' => user.surname,
          'email' => user.email,
          'role' => nil
        }
      end
    end

    def apps_for_team(team)
      team.app_instances.map do |app_instance|
        {
          'id' => app_instance.id,
          'name' => app_instance.name,
          'logo' => app_instance.app.logo
        }
      end
    end

    def hash_for_team(team)
      {
        'team' => {
          id: team.id,
          name: team.name,
          users: users_for_team(team),
          app_instances: apps_for_team(team)
        }
      }
    end

    #===============================================
    # Assignments
    #===============================================
    # Stub controller ability
    let!(:ability) { stub_ability }
    before { allow(ability).to receive(:can?).with(any_args).and_return(true) }
    before { sign_in user }
    # Stub user and user call
    let!(:app) { build(:app) }
    let!(:user) { build(:user) }
    let(:organization) { build(:organization) }
    let(:team) { build(:team, organization: organization) }
    #===============================================
    # Specs
    #===============================================
    describe 'PUT #add_users' do

      let!(:current_user_stub) { stub_user(user) }

      before { stub_api_v2(:get, "/apps", [app]) }
      before { stub_api_v2(:get, "/organizations/#{organization.id}", organization, %i(orga_relations)) }
      before { stub_api_v2(:get, "/teams/#{team.id}", team, %i(organization)) }
      before { stub_api_v2(:patch, "/teams/#{team.id}") }
      before { stub_audit_events }
      subject { put :add_users, id: team.id, team: {users: [{id: user.id}]} }

      # team reload
      before { stub_api_v2(:get, "/teams/#{team.id}", team, %i(organization users app_instances)) }
      context 'success' do
        before { subject }

        it 'returns a list of teams' do
          expect(response).to be_success
          expect(JSON.parse(response.body)).to eq(JSON.parse(hash_for_team(team).to_json))
        end
      end
    end
  end
end
