module MnoEnterprise::TestingSupport::SharedExamples::OrganizationSharedExamples
  include MnoEnterprise::TestingSupport::JpiV1TestHelper

  shared_examples 'organization update and remove' do
    describe 'PUT #update_member' do

      let(:email) { 'somemember@maestrano.com' }
      let(:member_role) { 'Member' }
      let(:member) { build(:user) }
      let(:email) { member.email }

      let(:new_member_role) { 'Power User' }
      let(:params) { {id: member.id, email: email, role: new_member_role} }

      # reloading organization
      before { stub_api_v2(:get, "/organizations/#{organization.id}", organization, %i(users orga_invites orga_relations)) }

      subject { put :update_member, id: organization.id, member: params }

      context 'with user' do
        let(:member_orga_relation) { build(:orga_relation, user_id: member.id, organization_id: organization.id, role: member_role) }
        let(:organization_stub) {
          organization.users << member
          organization.orga_relations << member_orga_relation
          stub_api_v2(:get, "/organizations/#{organization.id}", organization, %i(users orga_invites orga_relations credit_card invoices main_address))
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
          stub_api_v2(:get, "/organizations/#{organization.id}", organization, %i(users orga_invites orga_relations credit_card invoices main_address))
        }

        before { stub_api_v2(:get, "/organizations/#{organization.id}", organization, %i(users orga_invites orga_relations credit_card invoices main_address)) }
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

      it 'renders the user list' do
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
        stub_api_v2(:get, "/organizations/#{organization.id}", organization, %i(users orga_invites orga_relations credit_card invoices main_address))
      }
      # reloading organization
      before { stub_api_v2(:get, "/organizations/#{organization.id}", organization, %i(users orga_invites orga_relations)) }


      let(:params) { {email: 'somemember@maestrano.com'} }
      subject { put :remove_member, id: organization.id, member: params }

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
          stub_api_v2(:get, "/organizations/#{organization.id}", organization, %i(users orga_invites orga_relations credit_card invoices main_address))
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
