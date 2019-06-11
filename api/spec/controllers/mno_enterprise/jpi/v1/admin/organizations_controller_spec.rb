require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::Admin::OrganizationsController, type: :controller do
    include MnoEnterprise::TestingSupport::OrganizationsSharedHelpers
    include MnoEnterprise::TestingSupport::SharedExamples::JpiV1Admin

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
      organizations = [organization]
      allow(organizations).to receive(:loaded?).and_return(true)
      allow_any_instance_of(MnoEnterprise::User).to receive(:organizations).and_return(organizations)
      api_stub_for(get: "/organizations/#{organization.id}/invoices", response: from_api([invoice]))
      api_stub_for(get: "/organizations/#{organization.id}", response: from_api(organization))
      api_stub_for(get: "/organizations/#{organization.id}/org_invites", response: from_api([org_invite]))
      api_stub_for(get: "/org_invites?filter[organization_id]=#{organization.id}&filter[user_id]=#{user.id}&limit=1", response: from_api([org_invite]))
      api_stub_for(get: "/org_invites/#{org_invite.id}", response: from_api(org_invite))
      api_stub_for(put: "/org_invites/#{org_invite.id}", response: from_api([org_invite]))
    end

    # Used for show and create
    def stubs_for_show
      api_stub_for(get: "/organizations/#{organization.id}/users", response: from_api([user]))
      api_stub_for(get: "/organizations/#{organization.id}/app_instances", response: from_api([app_instance]))
      api_stub_for(get: "/organizations/#{organization.id}/credit_card", response: from_api([credit_card]))
    end

    let(:expected_hash_for_organizations) {
      {
        'organizations' => [{
          'id' => organization.id,
          'uid' => organization.uid,
          'name' => organization.name,
          'soa_enabled' => organization.soa_enabled,
          'created_at' => organization.created_at,
          'account_frozen' => organization.account_frozen,
          'financial_year_end_month' => organization.financial_year_end_month
        }],
        'metadata' => {'pagination' => {'count' => 1}}
      }
    }

    #===============================================
    # Specs
    #===============================================
    describe '#index' do
      subject { get :index }

      before do
        api_stub_for(get: "/organizations", response: from_api([organization]))
      end

      it_behaves_like 'a jpi v1 admin action'

      context 'success' do
        context 'index' do
          it 'returns a list of organizations' do
            expect(subject).to be_success
            expect(JSON.parse(response.body)).to eq(JSON.parse(expected_hash_for_organizations.to_json))
          end

          context 'when Account Manager is enabled' do
            before { Settings.merge!(admin_panel: {account_manager: {enabled: true}}) }
            after { Settings.reload! }

            # Remove the stub to  /organizations so we can test the params (filter, account_manager_id)
            before { api_stub_remove(get: "/organizations", response: from_api([organization])) }

            before { api_stub_for(get: "/organizations?account_manager_id=#{user.id}", response: from_api([organization])) }


            it 'returns a list of organizations' do
              expect(subject).to be_success
              expect(JSON.parse(response.body)).to eq(JSON.parse(expected_hash_for_organizations.to_json))
            end
          end
        end


        context 'search' do
          subject { get :index, terms: "{\"name.like\":\"%search%\"}" }

          # Remove the stub to  /organizations so we can test the params (filter, account_manager_id)
          before { api_stub_remove(get: "/organizations", response: from_api([organization])) }

          context 'when Account Manager is disabled' do
            before { api_stub_for(get: URI::encode("/organizations?filter[name.like]=%search%"), response: from_api([organization])) }

            it 'returns a list of organizations' do
              expect(subject).to be_success
              expect(JSON.parse(response.body)).to eq(JSON.parse(expected_hash_for_organizations.except('metadata').to_json))
            end
          end

          context 'when Account Manager is enabled' do
            before { Settings.merge!(admin_panel: {account_manager: {enabled: true}}) }
            after { Settings.reload! }

            before { api_stub_for(get: URI::encode("/organizations?account_manager_id=#{user.id}&filter[name.like]=%search%"), response: from_api([organization])) }

            it 'returns a list of organizations' do
              expect(subject).to be_success
              expect(JSON.parse(response.body)).to eq(JSON.parse(expected_hash_for_organizations.except('metadata').to_json))
            end
          end
        end
      end
    end

    describe 'GET #show' do
      subject { get :show, id: organization.id }

      before { stubs_for_show }

      it_behaves_like 'a jpi v1 admin action'

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

      before do
        api_stub_for(get: "/arrears_situations", response: from_api([arrears]))
      end

      it_behaves_like 'a jpi v1 admin action'

      context 'success' do
        before { subject }

        it 'returns arrears with the organization name' do
          expect(response).to be_success
          expect(JSON.parse(response.body)).to eq(JSON.parse(hash_for_arrears([arrears]).to_json))
        end
      end
    end

    describe 'POST #create' do
      subject { post :create, organization: params }

      before { api_stub_for(post: "/organizations", response: from_api([organization])) }

      let(:params) { FactoryGirl.attributes_for(:organization) }
      before { allow(MnoEnterprise::Organization).to receive(:create) { organization } }
      before { stubs_for_show }

      it_behaves_like 'a jpi v1 admin action'

      it 'creates the organization' do
        expect(MnoEnterprise::Organization).to receive(:create).with(params.slice(:name)) { organization }
        subject
      end

      it 'provision the app instances' do
        params[:app_nids] = ['xero', app_instance.app.nid]

        # Track the API call
        create = false
        stub = -> { create = true; from_api(app_instance) }
        api_stub_for(post: "/organizations/#{organization.id}/app_instances", response: stub)

        subject

        expect(create).to be true
      end
    end

    describe 'POST #invite_member' do
      before do
        # Track the api call
        @api_call = false
        stub = -> { @api_call = true; from_api(org_invite) }
        api_stub_for(post: "/organizations/#{organization.id}/org_invites", response: stub)
      end

      let(:params) { FactoryGirl.attributes_for(:user) }
      subject { post :invite_member, id: organization.id, user: params }

      context 'with existing user' do
        before { allow(MnoEnterprise::User).to receive(:find_by) { user } }

        it_behaves_like 'a jpi v1 admin action'

        it 'creates an invite' do
          subject
          expect(@api_call).to be true
        end
      end

      context 'with new user' do
        before { allow(MnoEnterprise::User).to receive(:find_by) { nil } }

        # Directly stubbing the controller method as user creation is a PITA to stub
        let(:new_user) { build(:user, params.slice(:email, :name, :surname, :phone)) }
        before { allow(controller).to receive(:create_unconfirmed_user) { new_user } }

        it_behaves_like 'a jpi v1 admin action'

        it 'creates a user' do
          expect(controller).to receive(:create_unconfirmed_user) { new_user }
          subject
        end

        it 'creates an invite' do
          subject
          expect(@api_call).to be true
        end
      end
    end
  end
end
