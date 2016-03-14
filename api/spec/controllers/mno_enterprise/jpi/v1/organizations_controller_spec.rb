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
    let(:user) { build(:user) }
    before { api_stub_for(get: "/users/#{user.id}", response: from_api(user)) }
    before { sign_in user }
    
    # Advanced features - currently disabled
    let!(:credit_card) { build(:credit_card, organization_id: organization.id) }
    let!(:invoice) { build(:invoice, organization_id: organization.id) }
    let!(:org_invite) { build(:org_invite, organization: organization) }
    
    # Stub organization + associations
    let(:organization) { build(:organization) }
    before { allow_any_instance_of(MnoEnterprise::User).to receive(:organizations).and_return([organization]) }

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
      end
    end

    # describe 'PUT #invite_members' do
    #   let(:team) { build(:team, organization: organization) }
    #   let(:params) { [{email: 'newmember@maestrano.com', role: 'Power User', team_id: team.id}] }
    #   subject { put :invite_members, id: organization.id, invites: params }
    #
    #   it_behaves_like "jpi v1 authorizable action"
    #
    #   context 'success' do
    #     before { subject }
    #
    #     it 'creates a new invite' do
    #       invite = organization.org_invites.first
    #       expect(invite.user_email).to eq(params.first[:email])
    #       expect(invite.user_role).to eq(params.first[:role])
    #       expect(invite.organization).to eq(organization)
    #       expect(invite.team).to eq(team)
    #       expect(invite.referrer).to eq(user)
    #     end
    #
    #     it 'returns a partial representation of the entity' do
    #       organization.reload
    #       expect(JSON.parse(response.body)).to eq(partial_hash_for_members(organization))
    #     end
    #   end
    # end

    # describe 'PUT #update_member' do
    #   let(:user) { build(:user) }
    #   let(:organization) { build(:organization) }
    #   let(:params) { { email: 'somemember@maestrano.com', role: 'Admin'} }
    #   subject { put :update_member, id: organization.id, member: params }
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
    #   context 'unauthorized as member' do
    #     let(:role) { 'Power User' }
    #     before { sign_in user }
    #     before { organization.add_user(user,role) }
    #     before { subject }
    #     it { expect(response.code).to eq("401") }
    #   end
    #
    #   context 'authorized with member' do
    #     let(:role) { 'Admin' }
    #     let(:member) { build(:user, email: params[:email]) }
    #     before { organization.add_user(user,role) }
    #     before { organization.add_user(member) }
    #     before { sign_in user }
    #     before { subject }
    #
    #     it 'updates the member role' do
    #       member.reload
    #       expect(member.role(organization)).to eq(params[:role])
    #     end
    #
    #     it 'returns a partial representation of the entity' do
    #       organization.reload
    #       expect(JSON.parse(response.body)).to eq(partial_hash_for_members(organization))
    #     end
    #   end
    #
    #   context 'authorized with invite' do
    #     let(:role) { 'Admin' }
    #     let!(:member) { build(:org_invite, user_email: params[:email], organization: organization) }
    #     before { organization.add_user(user,role) }
    #     before { sign_in user }
    #     before { subject }
    #
    #     it 'updates the member role' do
    #       member.reload
    #       expect(member.user_role).to eq(params[:role])
    #     end
    #
    #     it 'returns a partial representation of the entity' do
    #       organization.reload
    #       expect(JSON.parse(response.body)).to eq(partial_hash_for_members(organization))
    #     end
    #   end
    # end
    #
    # describe 'PUT #remove_member' do
    #   let(:user) { build(:user) }
    #   let(:organization) { build(:organization) }
    #   let(:params) { { email: 'somemember@maestrano.com', role: 'Admin'} }
    #   subject { put :remove_member, id: organization.id, member: params }
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
    #   context 'unauthorized as member' do
    #     let(:role) { 'Power User' }
    #     let!(:member) { build(:user, email: params[:email]) }
    #     before { sign_in user }
    #     before { organization.add_user(user,role) }
    #     before { subject }
    #     it { expect(response.code).to eq("401") }
    #   end
    #
    #   context 'authorized - with member' do
    #     let(:role) { 'Admin' }
    #     let(:member) { build(:user, email: params[:email]) }
    #     before { organization.add_user(user,role) }
    #     before { organization.add_user(member) }
    #     before { sign_in user }
    #     before { subject }
    #
    #     it 'remove the member' do
    #       member.reload
    #       expect(member.role(organization)).to be_nil
    #     end
    #
    #     it 'returns a partial representation of the entity' do
    #       organization.reload
    #       expect(JSON.parse(response.body)).to eq(partial_hash_for_members(organization))
    #     end
    #   end
    #
    #   context 'authorized - with invite' do
    #     let(:role) { 'Admin' }
    #     let!(:invite) { build(:org_invite, organization: organization, user_email: params[:email]) }
    #     before { organization.add_user(user,role) }
    #     before { sign_in user }
    #     before { subject }
    #
    #     it 'remove the member' do
    #       invite.reload
    #       expect(invite).to be_expired
    #     end
    #
    #     it 'returns a partial representation of the entity' do
    #       organization.reload
    #       expect(JSON.parse(response.body)).to eq(partial_hash_for_members(organization))
    #     end
    #   end
    # end

    # describe "PUT update_support_plan" do
    #   let(:user) { build(:user) }
    #   let(:organization) { build(:organization) }
    #
    #   before { allow_any_instance_of(CreditCard).to receive(:save_to_gateway).and_return(true) }
    #   subject { put :update_support_plan, id: organization.id, support_plan:'concierge' }
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
    #   context 'unauthorized as member' do
    #     let(:role) { 'Admin' }
    #     before { sign_in user }
    #     before { organization.add_user(user,role) }
    #     before { subject }
    #     it { expect(response.code).to eq("401") }
    #   end
    #
    #   context 'authorized' do
    #     let(:role) { 'Super Admin' }
    #     before { sign_in user }
    #     before { organization.add_user(user,role) }
    #     before { subject }
    #
    #     it 'updates the entity support plan' do
    #       organization.reload
    #       expect(organization.current_support_plan).to eq('concierge')
    #     end
    #
    #     it 'returns a partial representation of the entity' do
    #       organization.reload
    #       expect(JSON.parse(response.body)).to eq(partial_hash_for_organization(organization))
    #     end
    #   end
    # end

    # describe "POST training_session_req" do
    #   let(:user) { build(:user) }
    #   let(:organization) { build(:organization) }
    #
    #   before { allow_any_instance_of(CreditCard).to receive(:save_to_gateway).and_return(true) }
    #   subject { post :training_session_req, id: organization.id, message: 'I would like to be trained on blabla' }
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
    #   context '#NO concierge support' do
    #     before { sign_in user }
    #     before { organization.add_user(user) }
    #     before { subject }
    #
    #     it { expect(response.code).to eq("400") }
    #   end
    #
    #   context 'authorized' do
    #     let(:now) { Time.new("2014-01-01") }
    #     before {
    #       Timecop.freeze(now) do
    #         organization.update_support_plan('concierge')
    #       end
    #     }
    #     before { sign_in user }
    #     before { organization.add_user(user) }
    #     let(:delay) { double(:delay) }
    #     before { PartnerMailer.stub(:delay).and_return(delay) }
    #
    #     it "sends an email to the account manager with the customer's enquiry" do
    #       Timecop.freeze(now + 6.months) do
    #         expect(delay).to receive(:contact_partner).with({"message"=>"I would like to be trained on blabla", "first_name"=>user.name, "last_name"=>user.surname, "email"=>user.email})
    #         subject
    #       end
    #     end
    #
    #     it "consume a custom training session credit" do
    #       delay.stub(:contact_partner).and_return(true)
    #       Timecop.freeze(now + 8.months) do
    #         subject
    #         expect(organization.support_plan.custom_training_credits).to eq(0)
    #       end
    #     end
    #
    #     it 'returns a partial representation of the entity' do
    #       delay.stub(:contact_partner).and_return(true)
    #       Timecop.freeze(now + 6.months) do
    #         subject
    #         organization.reload
    #         expect(JSON.parse(response.body)).to eq(partial_hash_for_organization(organization))
    #       end
    #     end
    #   end
    # end

    # describe "PUT update_meta_data" do
    #   let(:user) { build(:user) }
    #   let(:organization) { build(:organization) }
    #   subject { put :update_meta_data, name:'field_example', value:'test', id: organization.id }
    #
    #   context "when organization has update rights" do
    #     let(:role) { 'Super Admin' }
    #     before { sign_in user }
    #     before { organization.add_user(user,role) }
    #
    #     it { expect(subject).to be_success }
    #
    #     it "calls put_meta_data with the rights args" do
    #       Organization.any_instance.should_receive(:put_meta_data).with('field_example','test')
    #       subject
    #     end
    #   end
    #
    #   context "when user is not logged in" do
    #     before { sign_in user }
    #     before { organization.add_user(user) }
    #
    #     it "is not successful" do
    #       expect(subject).to_not be_success
    #     end
    #   end
    # end

  end
end
