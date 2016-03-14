require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::Admin::OrganizationsController, type: :controller do
    include MnoEnterprise::TestingSupport::OrganizationsSharedHelpers
    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env["HTTP_ACCEPT"] = 'application/json' }

    def hash_for_arrears(arrears)
      {
          'in_arrears' => arrears.map { |a| partial_hash_for_arrears(a) }
      }
    end

    def partial_hash_for_arrears(arrear)
      {
          'name' => arrear.name,
          'amount' => AccountingjsSerializer.serialize(arrear.payment),
          'category' => arrear.category,
          'status' => arrear.status
      }
    end

    #===============================================
    # Assignments
    #===============================================

    # Stub user and user call
    let(:user) { build(:user, admin_role: 'admin') }
    before do
      api_stub_for(get: "/users/#{user.id}", response: from_api(user))
      sign_in user
    end


    # Stub organization + associations
    let!(:invoice) { build(:invoice, organization_id: organization.id) }
    let(:organization) { build(:organization) }
    let(:arrears) { build(:arrears_situation) }
    let(:org_invite) { build(:org_invite, organization: organization) }
    let(:app_instance) { build(:app_instance, organization: organization) }
    let(:credit_card) { build(:credit_card, organization: organization) }

    before do
      allow_any_instance_of(MnoEnterprise::User).to receive(:organizations).and_return([organization]) # ???
      api_stub_for(get: "/organizations/#{organization.id}/invoices", response: from_api([invoice]))
      api_stub_for(get: "/organizations", response: from_api([organization]))
      api_stub_for(get: "/organizations/#{organization.id}", response: from_api(organization))
      api_stub_for(get: "/organizations/#{organization.id}/users", response: from_api([user]))
      api_stub_for(get: "/organizations/#{organization.id}/org_invites", response: from_api([org_invite]))
      api_stub_for(get: "/organizations/#{organization.id}/app_instances", response: from_api([app_instance]))
      api_stub_for(get: "/organizations/#{organization.id}/credit_card", response: from_api([credit_card]))
      api_stub_for(get: "/arrears_situations", response: from_api([arrears]))
    end

    let(:expected_hash_for_organizations) {
      {
        'organizations' => [{
          'id' => organization.id,
          'uid' => organization.uid,
          'name' => organization.name,
          'soa_enabled' => organization.soa_enabled,
          'created_at' => organization.created_at,
          'credit_card' => {'presence' => organization.credit_card?}
        }],
        'metadata' => {'pagination' => {'count' => 1}}
      }
    }

    #===============================================
    # Specs
    #===============================================
    describe '#index' do
      subject { get :index }

      context 'success' do
        before { subject }

        it { expect(response).to be_success }

        it 'returns a list of organizations' do
          expect(JSON.parse(response.body)).to eq(JSON.parse(expected_hash_for_organizations.to_json))
        end
      end
    end

    describe 'GET #show' do
      subject { get :show, id: organization.id }

      context 'success' do
        before { subject }

        it { expect(response).to be_success }

        # TODO: admin and normal views are different we should test another way
        xit 'returns a complete description of the organization' do
          expect(JSON.parse(response.body)).to eq(JSON.parse(admin_hash_for_organization(organization).to_json))
        end
      end
    end

    describe 'GET #in_arrears' do
      subject { get :in_arrears }

      context 'success' do
        before { subject }

        it 'returns arrears with the organization name' do
          expect(response).to be_success
          expect(JSON.parse(response.body)).to eq(JSON.parse(hash_for_arrears([arrears]).to_json))
        end
      end
    end
  end
end
