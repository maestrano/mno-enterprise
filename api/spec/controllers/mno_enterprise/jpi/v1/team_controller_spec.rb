require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::TeamsController, type: :controller do
    include MnoEnterprise::TestingSupport::JpiV1TestHelper

    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env["HTTP_ACCEPT"] = 'application/json' }

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

    # Stub user and user call
    let(:user) { build(:user, :with_organizations) }
    let(:user2) { build(:user, :with_organizations, name: "Joe") }
    let(:organization) { build(:organization) }
    let(:team) { build(:team, organization: organization) }
    let(:app_instance) { build(:app_instance) }
    before do
      api_stub_for(get: "/users/#{user.id}", response: from_api(user))
      api_stub_for(get: "/users/#{user.id}/organizations", response: from_api(organization))
      api_stub_for(post: "/organizations", response: from_api(organization))
      api_stub_for(get: "/organizations/#{organization.id}/users", response: from_api([user]))
      api_stub_for(post: "/organizations/#{organization.id}/users", response: from_api(user))
      api_stub_for(get: "/organizations/#{organization.id}/teams", response: from_api([team]))
      api_stub_for(get: "/teams/#{team.id}", response: from_api(team))
      api_stub_for(get: "/teams/#{team.id}/app_instances", response: from_api([app_instance]))
      api_stub_for(get: "/teams/#{team.id}/users", response: from_api([user, user2]))
      sign_in user
    end

    #===============================================
    # Specs
    #===============================================
    describe 'PUT #add_users' do
      subject { put :add_users, id: team.id }

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
