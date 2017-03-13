require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::OrganizationsController, type: :controller do
    include MnoEnterprise::TestingSupport::JpiV1TestHelper
    include MnoEnterprise::TestingSupport::OrganizationsSharedHelpers

    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env["HTTP_ACCEPT"] = 'application/json' }
    #before { allow_any_instance_of(CreditCard).to receive(:save_to_gateway).and_return(true) }


    #===============================================
    # Assignments
    #===============================================
    # Stub controller ability
    let!(:ability) { stub_ability }
    before { allow(ability).to receive(:can?).with(any_args).and_return(true) }

    # Stub user and user call
    let(:user) { build(:user, role: 'Admin') }
    before { api_stub_for(get: "/users/#{user.id}", response: from_api(user)) }
    before { sign_in user }

    # Advanced features - currently disabled
    let!(:credit_card) { build(:credit_card, organization_id: organization.id) }
    let!(:invoice) { build(:invoice, organization_id: organization.id) }
    let!(:org_invite) { build(:org_invite, organization: organization) }

    # Stub organization + associations
    let(:organization) { build(:organization) }

    before do
      organizations = [organization]
      allow(organizations).to receive(:loaded?).and_return(true)
      allow_any_instance_of(MnoEnterprise::User).to receive(:organizations).and_return(organizations)
    end

    before { api_stub_for(post: "/organizations", response: from_api(organization)) }
    before { api_stub_for(put: "/organizations/#{organization.id}", response: from_api(organization)) }
    before { api_stub_for(delete: "/organizations/#{organization.id}", response: from_api(nil)) }

    before { api_stub_for(get: "/organizations/#{organization.id}/credit_card", response: from_api(credit_card)) }
    before { api_stub_for(put: "/credit_cards/#{credit_card.id}", response: from_api(credit_card)) }


    before { api_stub_for(get: "/organizations/#{organization.id}/invoices", response: from_api([invoice])) }
    before { api_stub_for(get: "/organizations/#{organization.id}/org_invites", response: from_api([org_invite])) }
    before { api_stub_for(get: "/organizations/#{organization.id}/users", response: from_api([user])) }
    before { api_stub_for(post: "/organizations/#{organization.id}/users", response: from_api(user)) }

    #===============================================
    # Specs
    #===============================================
    shared_examples "an organization management action" do
      context 'when Organization management is disabled' do
        before { Settings.merge!(organization_management: {enabled: false}) }
        after { Settings.reload! }

        it { is_expected.to have_http_status(:forbidden) }
      end
    end

    describe 'GET #index' do
      subject { get :index }

      it_behaves_like "jpi v1 protected action"

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

      it_behaves_like "jpi v1 protected action"

      context 'success' do
        before { subject }

        it 'returns a complete description of the organization' do
          expect(response).to be_success
          expect(JSON.parse(response.body)).to eq(JSON.parse(hash_for_organization(organization,user).to_json))
        end

        # context 'and super admin' do
        #   let(:role) { 'Super Admin' }
        #
        #   it 'includes additional details' do
        #     expect(response).to be_success
        #     expect(JSON.parse(response.body)).to eq(JSON.parse(hash_for_organization(organization,user).to_json))
        #   end
        # end
      end
    end

    describe 'POST #create' do
      let(:params) { { 'name' => organization.name } }
      subject { post :create, organization: params }

      it_behaves_like "jpi v1 protected action"
      it_behaves_like "an organization management action"

      context 'success' do
        before { subject }

        it 'creates the organization' do
          expect(assigns(:organization).name).to eq(organization.name)
        end

        it 'adds the user as Super Admin' do
          expect(assigns(:organization).users).to eq([user])
        end

        it 'returns a partial representation of the entity' do
          expect(JSON.parse(response.body)).to eq(hash_for_organization(organization,user))
        end
      end
    end

    describe 'PUT #update' do
      let(:params) { { 'name' => organization.name + 'a', 'soa_enabled' => !organization.soa_enabled } }
      subject { put :update, id: organization.id, organization: params }

      it_behaves_like "jpi v1 authorizable action"
      it_behaves_like "an organization management action"

      context 'success' do
        it 'updates the organization' do
          expect(organization).to receive(:save).and_return(true)
          subject
          expect(organization.name).to eq(params['name'])
          expect(organization.soa_enabled).to eq(params['soa_enabled'])
        end

        it 'returns a partial representation of the entity' do
          subject
          expect(JSON.parse(response.body)).to eq(hash_for_reduced_organization(organization))
        end
      end
    end

    describe 'DELETE #destroy' do
      subject { delete :destroy, id: organization.id }

      it_behaves_like 'jpi v1 authorizable action'
      it_behaves_like 'an organization management action'

      context 'success' do
        it 'deletes the organization' do
          expect(organization).to receive(:destroy)
          subject
        end
      end
    end

    # describe 'PUT #charge' do
    #   let(:organization) { build(:organization) }
    #   let(:user) { build(:user) }
    #   subject { put :charge, id: organization.id }
    #
    #   context 'guest' do
    #     before { subject }
    #     it { expect(response.code).to eq("401") }
    #   end
    #
    #   context 'unauthorized as guest' do
    #     before { sign_in user }
    #     before { subject }
    #     it { expect(response.code).to eq("401") }
    #   end
    #
    #   context 'unauthorized as an admin' do
    #     let(:role) { 'Admin' }
    #     before { sign_in user }
    #     before { organization.add_user(user,role) }
    #     before { subject }
    #     it { expect(response.code).to eq("401") }
    #   end
    #
    #   context 'when the user is authorized as a Super Admin' do
    #     let(:role) { 'Super Admin' }
    #     let(:payment) { build(:payment) }
    #     before { sign_in user }
    #     before { organization.add_user(user,role) }
    #     before { allow_any_instance_of(Organization).to receive(:charge).and_return(payment) }
    #
    #     context 'with a successful payment' do
    #     before { subject }
    #       it 'returns "success" and the payment object' do
    #         expect(JSON.parse(response.body)['status']).to eq('success')
    #         expect(JSON.parse(response.body)['data'].to_json).to eq(payment.to_json)
    #       end
    #     end
    #
    #     context 'with a failed payment' do
    #       before { payment.success = false; payment.save }
    #       before { subject }
    #       it 'returns "fail" and the payment object' do
    #         expect(JSON.parse(response.body)['status']).to eq('fail')
    #         expect(JSON.parse(response.body)['data'].to_json).to eq(payment.to_json)
    #       end
    #     end
    #
    #     context 'with a fail in the charge function' do
    #       let(:payment) { nil }
    #       before { subject }
    #       it 'returns "error" and data is nil' do
    #         expect(JSON.parse(response.body)['status']).to eq('error')
    #         expect(JSON.parse(response.body)['data']).to eq(nil)
    #       end
    #     end
    #   end
    # end

    describe 'PUT #update_billing' do
      let(:params) { attributes_for(:credit_card) }
      subject { put :update_billing, id: organization.id, credit_card: params }

      it_behaves_like "jpi v1 protected action"
      it_behaves_like "an organization management action"

      context 'authorized' do
        it 'updates the entity credit card' do
          expect_any_instance_of(MnoEnterprise::CreditCard).to receive(:save).and_return(true)
          subject
          expect(organization.credit_card).to_not be_nil
        end

        it 'returns a partial representation of the entity' do
          subject
          expect(JSON.parse(response.body)).to eq(partial_hash_for_credit_card(organization.credit_card))
        end

        describe 'when payment restrictions are set' do
          before { organization.meta_data = {payment_restriction: [:visa]} }
          let(:visa) { '4111111111111111' }
          let(:mastercard) { '5105105105105100' }

          context 'with a valid type' do
            before { params.merge!(number: visa) }
            it 'updates the entity credit card' do
              expect_any_instance_of(MnoEnterprise::CreditCard).to receive(:save).and_return(true)
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
            before { params.merge!(number: mastercard) }
            it 'does not the entity credit card' do
              expect_any_instance_of(MnoEnterprise::CreditCard).not_to receive(:save)
              subject
              expect(organization.credit_card.errors).to_not be_empty
            end

            it 'returns an error' do
              subject
              expect(response).to have_http_status(:bad_request)
              expect(JSON.parse(response.body)).to eq({"number" => ["Payment is limited to Visa Card Holders"]})
            end
          end
        end
      end
    end

    describe 'PUT #invite_members' do
      before { api_stub_for(post: "/organizations/#{organization.id}/org_invites", response: from_api(org_invite)) }

      let(:team) { build(:team, organization: organization) }
      let(:params) { [{email: 'newmember@maestrano.com', role: 'Power User', team_id: team.id}] }
      subject { put :invite_members, id: organization.id, invites: params }

      it_behaves_like "jpi v1 authorizable action"
      it_behaves_like "an organization management action"

      context 'succcess' do
        let(:relation) { instance_double('Her::Model::Relation') }
        before do
          allow(relation).to receive(:active).and_return(relation)
        end

        it 'creates an invitation' do
          # For the view
          allow(organization).to receive(:members).and_return([org_invite])

          expect(organization).to receive(:org_invites).and_return(relation)
          expect(relation).to receive(:create).with(
            user_email: 'newmember@maestrano.com',
            user_role: 'Power User',
            team_id: team.id.to_s,
            referrer_id: user.id
          ).and_return(org_invite)
          subject
        end

        it 'sends a notification email' do
          expect(MnoEnterprise::SystemNotificationMailer).to receive(:organization_invite).with(org_invite).and_call_original
          subject
        end

        it 'returns a partial representation of the entity' do
          subject
          expect(JSON.parse(response.body)).to eq({'members' => partial_hash_for_members(organization)})
        end
      end
    end

    describe 'PUT #update_member' do
    #   let(:user) { build(:user) }
    #   let(:organization) { build(:organization) }

      before { api_stub_for(put: "/org_invites/#{org_invite.id}")}

      let(:email) { 'somemember@maestrano.com' }
      let(:role) { 'Admin' }
      let(:params) { { email: email, role: role} }
      subject { put :update_member, id: organization.id, member: params }

      it_behaves_like "jpi v1 authorizable action"
      it_behaves_like "an organization management action"

      context 'with user' do
        let(:member) { build(:user) }
        let(:email) { member.email }
        # No verifying double as this rely on method_missing and proxying
        let(:collection) { double('Her::Collection') }

        before do
          allow(collection).to receive(:to_a).and_return([member])
          allow(organization).to receive(:users).and_return(collection)
        end

        # Happy path
        it 'updates the member role' do
          expect(collection).to receive(:update).with(id: member.id, role: params[:role])
          subject
        end

        # Exceptions
        context 'when admin' do
          context 'assign super admin role' do
            let(:role) { 'Super Admin' }
            it 'denies access' do
              expect(subject).to_not be_successful
              expect(subject.code).to eq('403')
            end
          end

          context 'edit super admin' do
            let(:member) { build(:user, role: 'Super Admin') }
            let(:role) { 'Member' }

            it 'denies access' do
              expect(subject).to_not be_successful
              expect(subject.code).to eq('403')
            end
          end
        end

        context 'last super admin changing his role' do
          let(:user) { build(:user, role: 'Super Admin') }
          let(:member) { user }
          let(:role) { 'Member' }

          it 'denies access' do
            expect(subject).to_not be_successful
            expect(subject.code).to eq('403')
          end
        end
      end

      context 'with invite' do
        let(:relation) { instance_double('Her::Model::Relation') }

        before do
          allow(relation).to receive(:active).and_return(relation)
          allow(relation).to receive(:where).and_return([org_invite])

          allow(organization).to receive(:org_invites).and_return(relation)
          # For the view
          allow(organization).to receive(:members).and_return([org_invite])
        end


        # Happy Path
        it 'updates the member role' do
          expect(org_invite).to receive(:update).with(user_role: params[:role])
          subject
        end

        # Exceptions
        context 'when admin' do
          context 'assign super admin role' do
            let(:role) { 'Super Admin' }
            it 'denies access' do
              expect(subject).to_not be_successful
              expect(subject.code).to eq('403')
            end
          end

          context 'edit super admin' do
            let!(:org_invite) { build(:org_invite, organization: organization, user_role: 'Super Admin') }
            let(:role) { 'Member' }

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
      before do
        api_stub_for(delete: "/organizations/#{organization.id}/users/#{user.id}", response: from_api(nil))
        api_stub_for(put: "/org_invites/#{org_invite.id}", response: from_api(nil))
      end

      let(:params) { { email: 'somemember@maestrano.com' } }
      subject { put :remove_member, id: organization.id, member: params }

      it_behaves_like "jpi v1 authorizable action"
      it_behaves_like "an organization management action"

      context 'with user' do
        let(:params) { { email: user.email } }
        it 'removes the member' do
          expect(organization).to receive(:remove_user).with(user).and_call_original
          subject
        end
      end

      context 'with invite' do
        let(:relation) { instance_double('Her::Model::Relation') }
        before do
          allow(relation).to receive(:active).and_return(relation)
          allow(relation).to receive(:where).and_return([org_invite])

          allow(organization).to receive(:org_invites).and_return(relation)
          # For the view
          allow(organization).to receive(:members).and_return([org_invite])
        end

        it 'removes the member' do
          expect(org_invite).to receive(:cancel!)
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
