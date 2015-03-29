require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::OrganizationsController, type: :controller do
    include JpiV1TestHelper
    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env["HTTP_ACCEPT"] = 'application/json' }
    #before { allow_any_instance_of(CreditCard).to receive(:save_to_gateway).and_return(true) }
    
    # def partial_hash_for_credit_card(cc)
    #   {
    #     'credit_card' => {
    #       'id' => cc.id,
    #       'title' => cc.title,
    #       'first_name' => cc.first_name,
    #       'last_name' => cc.last_name,
    #       'number' => cc.masked_number,
    #       'month' => cc.month,
    #       'year' => cc.year,
    #       'country' => cc.country,
    #       'verification_value' => 'CVV',
    #       'billing_address' => cc.billing_address,
    #       'billing_city' => cc.billing_city,
    #       'billing_postcode' => cc.billing_postcode,
    #       'billing_country' => cc.billing_country
    #     }
    #   }
    # end

    def partial_hash_for_members(organization)
      list = []
      organization.users.each do |user|
        list.push({
          'id' => user.id,
          'entity' => 'User',
          'name' => user.name,
          'surname' => user.surname,
          'email' => user.email,
          'role' => user.role(organization)
        })
      end

      organization.org_invites.each do |invite|
        list.push({
          'id' => invite.id,
          'entity' => 'OrgInvite',
          'email' => invite.user_email,
          'role' => invite.user_role
        })
      end

      return list
    end

    # def partial_hash_for_arrears_situations(situations)
    #   array = []
    #   situations.each do |sit|
    #     array.push({
    #       id: sit.id,
    #       owner_id: sit.owner_id,
    #       owner_type: sit.owner_type,
    #       status: sit.status,
    #       category: sit.category
    #       })
    #   end
    #
    #   return { arrears_situations: array }
    # end

    def partial_hash_for_organization(organization)
      ret = {
        'id' => organization.id,
        'name' => organization.name,
        'soa_enabled' => organization.soa_enabled,
        #'current_support_plan' => organization.current_support_plan,
      }
      
      # if organization.support_plan
      #   ret['organization'].merge!({
      #     'custom_training_credits' => organization.support_plan.custom_training_credits
      #   })
      # end
      
      return ret
    end

    def partial_hash_for_current_user(organization,user)
      {
        'id' => user.id,
        'name' => user.name,
        'surname' => user.surname,
        'email' => user.email,
        'role' => user.role(organization)
      }
    end

    # def partial_hash_for_billing(organization)
    #   {
    #     'billing' => {
    #       'current' => organization.current_billing,
    #       'credit' => organization.current_credit,
    #       'free_trial_end_at' => organization.free_trial_end_at,
    #       'under_free_trial' => organization.under_free_trial?
    #     }
    #   }
    # end
    #
    # def partial_hash_for_invoices(organization)
    #   hash = {'invoices' => []}
    #   organization.invoices.order("ended_at DESC").each do |invoice|
    #     hash['invoices'].push({
    #       'period' => invoice.period_label,
    #       'amount' => invoice.total_due,
    #       'paid' => invoice.paid?,
    #       'link' => invoice_path(invoice.slug),
    #     })
    #   end
    #
    #   return hash
    # end
    
    def hash_for_organizations(organizations)
      { 
        'organizations' => organizations.map { |o| partial_hash_for_organization(o) }
      }
    end
    
    def hash_for_reduced_organization(organization)
      { 
        'organization' => partial_hash_for_organization(organization)
      }
    end
    
    def hash_for_organization(organization,user)
      hash = { 
        'organization' => partial_hash_for_organization(organization),
        'current_user' => partial_hash_for_current_user(organization,user)
      }
      hash['organization'].merge!(
        'members' => partial_hash_for_members(organization)
      )

      # if user.role(organization) == 'Super Admin'
      #   hash.merge!(partial_hash_for_billing(organization))
      #   hash.merge!(partial_hash_for_invoices(organization))
      #
      #   if (cc = organization.credit_card)
      #     hash.merge!(partial_hash_for_credit_card(cc))
      #   end
      #
      #   if (situations = organization.arrears_situations)
      #     hash.merge!(partial_hash_for_arrears_situations(situations))
      #   end
      # end

      return hash
    end

    #===============================================
    # Assignments
    #===============================================
    # Stub controller ability
    let!(:ability) { stub_ability }
    before { allow(ability).to receive(:can?).with(any_args).and_return(true) }
    
    # Stub user and user call
    let(:user) { build(:user) }
    before { api_stub_for(MnoEnterprise::User, method: :get, path: "/users/#{user.id}", response: from_api(user)) }
    before { sign_in user }
    
    # Advanced features - currently disabled
    # let!(:credit_card) { build(:credit_card, owner: organization) }
    # let!(:invoice) { build(:invoice, invoicable: organization) }
    let!(:org_invite) { build(:org_invite, organization: organization) }
    
    # Stub organization + associations
    let(:organization) { build(:organization) }
    before { allow_any_instance_of(MnoEnterprise::User).to receive(:organizations).and_return([organization]) }
    before { api_stub_for(MnoEnterprise::Organization, method: :get, path: "/organizations/#{organization.id}/users", response: from_api([user])) }
    before { api_stub_for(MnoEnterprise::Organization, method: :put, path: "/organizations/#{organization.id}", response: from_api(organization)) }
    
    before { allow(organization).to receive(:users).and_return([user]) }
    before { allow(organization).to receive(:org_invites).and_return([org_invite]) }
    
    
    
    
    
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

    # describe 'PUT #update_billing' do
    #   let(:user) { build(:user) }
    #   let(:organization) { build(:organization) }
    #   let(:params) { attributes_for(:credit_card) }
    #
    #   before { allow_any_instance_of(CreditCard).to receive(:save_to_gateway).and_return(true) }
    #   subject { put :update_billing, id: organization.id, credit_card: params }
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
    #     it 'updates the entity credit card' do
    #       organization.reload
    #       expect(organization.credit_card).to_not be_nil
    #     end
    #
    #     it 'returns a partial representation of the entity' do
    #       organization.reload
    #       expect(JSON.parse(response.body)).to eq(partial_hash_for_credit_card(organization.credit_card))
    #     end
    #   end
    # end

    # describe 'PUT #invite_members' do
    #   let(:team) { build(:org_team, organization: organization) }
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