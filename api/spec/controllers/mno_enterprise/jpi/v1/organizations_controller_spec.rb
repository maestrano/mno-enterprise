require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::OrganizationsController, type: :controller do
    include MnoEnterprise::TestingSupport::JpiV1TestHelper
    include MnoEnterprise::TestingSupport::OrganizationsSharedHelpers

    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env['HTTP_ACCEPT'] = 'application/json' }

    #===============================================
    # Assignments
    #===============================================
    # Stub controller ability
    let!(:ability) { stub_ability }
    before { allow(ability).to receive(:can?).with(any_args).and_return(true) }

    before { stub_audit_events }

    # Stub organization + associations
    let(:metadata) { {} }
    let!(:organization) { build(:organization, metadata: metadata, orga_invites: [], users: [], orga_relations: [], credit_card: credit_card) }
    let(:role) { 'Admin' }
    let!(:user) {
      u = build(:user, organizations: [organization], orga_relations: [orga_relation], dashboards: [])
      orga_relation.user_id = u.id
      u
    }
    let!(:orga_relation) { build(:orga_relation, organization_id: organization.id, role: role) }

    let!(:organization_stub) { stub_api_v2(:get, "/organizations/#{organization.id}", organization, %i(users orga_invites orga_relations credit_card)) }
    # Stub user and user call
    let!(:current_user_stub) { stub_user(user) }

    before { sign_in user }

    # Advanced features - currently disabled
    let!(:credit_card) { build(:credit_card) }
    let!(:invoice) { build(:invoice, organization_id: organization.id) }
    let!(:orga_invite) { build(:orga_invite, organization: organization) }

    #===============================================
    # Specs
    #===============================================
    shared_examples 'an organization management action' do
      context 'when Organization management is disabled' do
        before { Settings.merge!(dashboard: {organization_management: {enabled: false}}) }
        after { Settings.reload! }

        it { is_expected.to have_http_status(:forbidden) }
      end
    end

    describe 'GET #index' do
      subject { get :index }
      it_behaves_like 'jpi v1 protected action'

      context 'success' do
        before { subject }

        it 'returns a list of organizations' do
          expect(response).to be_success
          expect(JSON.parse(response.body)).to eq(JSON.parse(hash_for_organizations([organization]).to_json))
        end
      end
    end

    describe 'GET #show' do
      subject { get :show, id: organization.id }

      it_behaves_like 'jpi v1 protected action'

      context 'success' do
        before { subject }

        it 'returns a complete description of the organization' do
          expect(response).to be_success
          expect(JSON.parse(response.body)).to eq(JSON.parse(hash_for_organization(organization, user).to_json))
        end
      end
    end

    describe 'POST #create' do
      let(:params) { {'name' => organization.name} }
      subject { post :create, organization: params }
      before { stub_api_v2(:post, '/organizations', organization) }
      before { stub_api_v2(:post, '/orga_relations', orga_relation) }
      # reloading organization
      before { stub_api_v2(:get, "/organizations/#{organization.id}", organization, %i(users orga_invites orga_relations)) }
      it_behaves_like 'jpi v1 protected action'
      it_behaves_like 'an organization management action'

      context 'success' do
        before { subject }

        it 'creates the organization' do
          expect(assigns(:organization).name).to eq(organization.name)
        end
        # TODO: Fix Specs
        xit 'adds the user as Super Admin' do
          expect(assigns(:organization).users.first.id).to eq(user.id)
        end

      end
    end

    describe 'PUT #update' do

      let(:params) { {'name' => organization.name + 'a', 'soa_enabled' => !organization.soa_enabled} }
      before { stub_api_v2(:patch, "/organizations/#{organization.id}", updated_organization) }
      let!(:updated_organization) { build(:organization, name: params['name'], id: organization.id, soa_enabled: params['soa_enabled']) }

      subject { put :update, id: organization.id, organization: params }

      it_behaves_like 'jpi v1 authorizable action'
      it_behaves_like 'an organization management action'

      context 'success' do

        it 'updates the organization' do
          subject
          expect(assigns(:organization).name).to eq(params['name'])
          expect(assigns(:organization).soa_enabled).to eq(params['soa_enabled'])
        end

        it 'returns a partial representation of the entity' do
          subject
          expect(JSON.parse(response.body)).to eq(hash_for_reduced_organization(updated_organization))
        end
      end
    end

    describe 'DELETE #destroy' do
      before { stub_api_v2(:delete, "/organizations/#{organization.id}") }
      subject { delete :destroy, id: organization.id }
      it_behaves_like 'jpi v1 authorizable action'
      it_behaves_like 'an organization management action'
      context 'success' do
        it 'deletes the organization' do
          subject
        end
      end
    end

    describe 'PUT #update_billing' do
      let(:params) { attributes_for(:credit_card) }
      let!(:credit_card_stub) { stub_api_v2(:patch, "/credit_cards/#{credit_card.id}", credit_card) }
      subject { put :update_billing, id: organization.id, credit_card: params }
      it_behaves_like 'jpi v1 protected action'
      it_behaves_like 'an organization management action'

      context 'new credit card' do
        let(:credit_card) { nil }
        let(:created_credit_card) { build(:credit_card) }
        let!(:credit_card_stub) { stub_api_v2(:post, '/credit_cards', created_credit_card) }
        it 'create a new card' do
          subject
          expect(credit_card_stub).to have_been_requested
        end
      end

      context 'authorized' do
        it 'updates the entity credit card' do
          subject
          expect(organization.credit_card).to_not be_nil
        end
        it do
          subject
          expect(credit_card_stub).to have_been_requested
        end
        it 'returns a partial representation of the entity' do
          subject
          expect(JSON.parse(response.body)).to eq(partial_hash_for_credit_card(organization.credit_card))
        end

        describe 'when payment restrictions are set' do
          let(:metadata) { {payment_restriction: [:visa]} }
          let(:visa) { '4111111111111111' }
          let(:mastercard) { '5105105105105100' }

          context 'with a valid type' do
            before { params[:number] = visa }
            before { expect_any_instance_of(MnoEnterprise::CreditCard).to receive(:update_attributes) }
            it 'updates the entity credit card' do
              subject
              expect(organization.credit_card).to_not be_nil
              expect(organization.credit_card).to be_valid
            end

            it 'returns a partial representation of the entity' do
              subject
              expect(JSON.parse(response.body)).to eq(partial_hash_for_credit_card(organization.credit_card))
            end
          end

          context 'with an invalid type' do
            before { params[:number] = mastercard }
            before { expect_any_instance_of(MnoEnterprise::CreditCard).not_to receive(:update_attributes) }


            it 'does not update the entity credit card' do
              subject
              expect(assigns(:credit_card).errors).to_not be_empty
            end
            it 'returns an error' do
              subject
              expect(response).to have_http_status(:bad_request)
              expect(JSON.parse(response.body)).to eq({'number' => ['Payment is limited to Visa Card Holders']})
            end
          end
        end
      end
    end

    describe 'PUT #invite_members' do
      # organization reload
      before { stub_api_v2(:get, "/organizations/#{organization.id}", organization, %i(users orga_invites orga_relations)) }

      before { stub_api_v2(:get, "/orga_invites/#{orga_invite.id}", orga_invite, %i(user organization team referrer)) }
      before { stub_api_v2(:post, "/orga_invites", orga_invite) }
      before { stub_api_v2(:patch, "/orga_invites/#{organization.id}", orga_invite) }

      let(:team) { build(:team, organization: organization) }
      let(:params) { [{email: 'newmember@maestrano.com', role: 'Power User', team_id: team.id}] }
      subject { put :invite_members, id: organization.id, invites: params }

      it_behaves_like 'jpi v1 authorizable action'
      it_behaves_like 'an organization management action'

      context 'succcess' do

        it 'creates an invitation' do
          # For the view
          expect(MnoEnterprise::OrgaInvite).to receive(:create).with(
            user_email: 'newmember@maestrano.com',
            user_role: 'Power User',
            organization_id: organization.id,
            team_id: team.id.to_s,
            referrer_id: user.id
          ).and_return(orga_invite)
          subject
        end

        it 'sends a notification email' do
          expect(MnoEnterprise::SystemNotificationMailer).to receive(:organization_invite).and_call_original
          subject
        end

        it 'returns a partial representation of the entity' do
          subject
          expect(JSON.parse(response.body)).to eq({'members' => partial_hash_for_members(organization)})
        end
      end
    end

    describe 'PUT #update_member' do

      let(:email) { 'somemember@maestrano.com' }
      let(:member_role) { 'Member' }
      let(:member) { build(:user) }
      let(:email) { member.email }

      let(:new_member_role) { 'Power User' }
      let(:params) { {email: email, role: new_member_role} }

      # reloading organization
      before { stub_api_v2(:get, "/organizations/#{organization.id}", organization, %i(users orga_invites orga_relations)) }

      subject { put :update_member, id: organization.id, member: params }
      it_behaves_like 'jpi v1 authorizable action'
      it_behaves_like 'an organization management action'

      context 'with user' do
        let(:member_orga_relation) { build(:orga_relation, user_id: member.id, organization_id: organization.id, role: member_role) }
        let(:organization_stub) {
          organization.users << member
          organization.orga_relations << member_orga_relation
          stub_api_v2(:get, "/organizations/#{organization.id}", organization, %i(users orga_invites orga_relations credit_card))
        }
        before { stub_api_v2(:get, "/orga_relations", [member_orga_relation], [], {filter: {organization_id: organization.id, user_id: member.id}, page:{ number: 1, size: 1}}) }
        before { stub_api_v2(:post, "/orga_relations/#{member_orga_relation.id}", orga_relation) }
        before { stub_api_v2(:patch, "/orga_relations/#{member_orga_relation.id}") }

        # Happy path
        it 'updates the member role' do
          subject
        end
        # Exceptions
        context 'when admin' do
          let(:role) { 'Admin' }
          context 'assign super admin role' do
            let(:new_member_role) { 'Super Admin' }
            it 'denies access' do
              expect(subject).to_not be_successful
              expect(subject.code).to eq('403')
            end
          end
          context 'edit super admin' do
            let(:member_role) { 'Super Admin' }
            let(:new_member_role) { 'Member' }
            it 'denies access' do
              expect(subject).to_not be_successful
              expect(subject.code).to eq('403')
            end
          end
        end

        context 'last super admin changing his role' do
          let(:role) { 'Super Admin' }
          let(:member_role) { role }
          let(:member) { build(:user, id: user.id, email: user.email) }
          let(:new_member_role) { 'Member' }
          it 'denies access' do
            expect(subject).to_not be_successful
            expect(subject.code).to eq('403')
          end
        end
      end

      context 'with invite' do
        let(:orga_invite) { build(:orga_invite, user_id: member.id, organization_id: organization.id, user_role: member_role, status: 'pending', user_email: email) }
        let!(:organization_stub) {
          organization.orga_invites << orga_invite
          stub_api_v2(:get, "/organizations/#{organization.id}", organization, %i(users orga_invites orga_relations credit_card))
        }

        before { stub_api_v2(:get, "/organizations/#{organization.id}", organization, %i(users orga_invites orga_relations credit_card)) }
        # reloading organization
        before { stub_api_v2(:get, "/organizations/#{organization.id}", organization, %i(users orga_invites orga_relations)) }

        # Happy Path
        it 'updates the member role' do
          expect_any_instance_of(MnoEnterprise::OrgaInvite).to receive(:update_attributes).with(user_role: params[:role])
          subject
        end

        # Exceptions
        context 'when admin' do
          let(:role) { 'Admin' }
          context 'assign super admin role' do
            let(:member_role) { 'Super Admin' }
            it 'denies access' do
              expect(subject).to_not be_successful
              expect(subject.code).to eq('403')
            end
          end

          context 'edit super admin' do
            let(:member_role) { 'Super Admin' }
            let(:new_member_role) { 'Member' }

            it 'denies access' do
              expect(subject).to_not be_successful
              expect(subject.code).to eq('403')
            end
          end
        end
      end

      it 'renders a the user list' do
        subject
        expect(JSON.parse(response.body)).to eq({'members' => partial_hash_for_members(organization)})
      end
    end

    describe 'PUT #remove_member' do

      let(:member) { build(:user) }
      let(:member_orga_relation) { build(:orga_relation, user_id: member.id, organization_id: organization.id) }

      let!(:organization_stub) {
        organization.users << member
        organization.orga_relations << member_orga_relation
        stub_api_v2(:get, "/organizations/#{organization.id}", organization, %i(users orga_invites orga_relations credit_card))
      }
      # reloading organization
      before { stub_api_v2(:get, "/organizations/#{organization.id}", organization, %i(users orga_invites orga_relations)) }


      let(:params) { {email: 'somemember@maestrano.com'} }
      subject { put :remove_member, id: organization.id, member: params }

      it_behaves_like 'jpi v1 authorizable action'
      it_behaves_like 'an organization management action'

      context 'with user' do
        before { stub_api_v2(:delete, "/orga_relations/#{member_orga_relation.id}") }
        let(:params) { {email: member.email} }
        it 'removes the member' do
          subject
        end
      end

      context 'with invite' do
        let(:orga_invite) { build(:orga_invite, user_id: member.id, organization_id: organization.id, status: 'pending', user_email: member.email) }
        let!(:organization_stub) {
          organization.orga_invites << orga_invite
          stub_api_v2(:get, "/organizations/#{organization.id}", organization, %i(users orga_invites orga_relations credit_card))
        }

        before { stub_api_v2(:get, "/orga_invites/#{orga_invite.id}/decline")}
        it 'removes the member' do
          subject
        end
      end

      it 'renders a the user list' do
        subject
        expect(JSON.parse(response.body)).to eq({'members' => partial_hash_for_members(organization)})
      end
    end
  end
end
