require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::Admin::OrganizationsController, type: :controller do
    include MnoEnterprise::TestingSupport::OrganizationsSharedHelpers
    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env["HTTP_ACCEPT"] = 'application/json' }

    #===============================================
    # Assignments
    #===============================================
    # Stub controller ability
    # let!(:ability) { stub_ability }
    # before { allow(ability).to receive(:can?).with(any_args).and_return(true) }

    # Stub user and user call
    let(:user) { build(:user, admin_role: 'admin') }
    before do
      api_stub_for(get: "/users/#{user.id}", response: from_api(user))
      sign_in user
    end


    # Stub organization + associations
    let(:organization) { build(:organization) }
    let(:org_invite) { build(:org_invite, organization: organization) }
    let(:app_instance) { build(:app_instance, organization: organization) }
    let(:credit_card) { build(:credit_card, organization: organization) }

    before do
      allow_any_instance_of(MnoEnterprise::User).to receive(:organizations).and_return([organization]) # ???
      api_stub_for(get: "/organizations", response: from_api([organization]))
      api_stub_for(get: "/organizations/#{organization.id}", response: from_api(organization))
      api_stub_for(get: "/organizations/#{organization.id}/users", response: from_api([user]))
      api_stub_for(get: "/organizations/#{organization.id}/org_invites", response: from_api([org_invite]))
      api_stub_for(get: "/organizations/#{organization.id}/app_instances", response: from_api([app_instance]))
      api_stub_for(get: "/organizations/#{organization.id}/credit_card", response: from_api([credit_card]))
    end


    #===============================================
    # Specs
    #===============================================
    describe '#index' do
      subject { get :index }

      context 'success' do
        before { subject }

        it 'returns a list of organizations' do
          expect(response).to be_success
          expect(JSON.parse(response.body)).to eq(JSON.parse(hash_for_organizations([organization], true).to_json))
        end
      end
    end

    describe 'GET #show' do
      subject { get :show, id: organization.id }

      context 'success' do
        before { subject }

        it 'returns a complete description of the organization' do
          expect(response).to be_success
          expect(JSON.parse(response.body)).to eq(JSON.parse(hash_for_organization(organization, user).to_json))
        end
      end
    end

    describe 'GET #in_arrears' do
      subject { get :in_arrears }

      context 'success' do
        before { subject }

        it 'returns a complete description of the organization with arrears status' do
          expect(response).to be_success
          expect(JSON.parse(response.body)).to eq(JSON.parse(hash_for_organizations_in_arrears([organization], true).to_json))
        end
      end
    end
  end
end