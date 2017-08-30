require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::Admin::SubTenantsController, type: :controller do
    include MnoEnterprise::TestingSupport::SharedExamples::JpiV1Admin
    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env['HTTP_ACCEPT'] = 'application/json' }

    def hash_for_sub_tenants(sub_tenants)
      {
        'sub_tenants' => sub_tenants.map { |s| partial_hash_for_sub_tenant(s) },
        'metadata' => {'pagination' => {'count' => sub_tenants.count}}
      }
    end

    def hash_for_sub_tenant(s)
      hash = partial_hash_for_sub_tenant(s).merge(
        {
          'clients' => s.clients.map { |c| hash_for_client(c) },
          'account_managers' => s.account_managers.map { |c| hash_account_manager(c) },
        })
      {'sub_tenant' => hash}
    end

    def partial_hash_for_sub_tenant(s)
      {
        'id' => s.id,
        'name' => s.name,
        'created_at' => s.created_at,
        'updated_at' => s.updated_at,
        'client_ids' => s.client_ids,
        'account_manager_ids' => s.account_manager_ids
      }
    end

    def hash_for_client(client)
      {
        'id' => client.id,
        'uid' => client.uid,
        'name' => client.name,
        'created_at' => client.created_at
      }
    end

    def hash_account_manager(user)
      {
        'id' => user.id,
        'uid' => user.uid,
        'name' => user.name,
        'surname' => user.surname,
        'email' => user.email,
        'created_at' => user.created_at,
        'admin_role' => user.admin_role
      }
    end

    shared_examples_for 'unauthorized access' do
      it { expect(subject).to_not be_success }
      it do
        subject
        expect(response.status).to eq(401)
      end
    end

    #===============================================
    # Specs
    #===============================================
    let(:current_user) { build(:user, :admin) }
    let(:user) { build(:user) }
    let(:organization) { build(:organization) }
    let(:sub_tenant) { build(:sub_tenant, account_managers: [user], clients: [organization]) }

    before do
      api_stub_for(get: '/sub_tenants', response: from_api([sub_tenant]))
      api_stub_for(get: "/sub_tenants/#{sub_tenant.id}", response: from_api(sub_tenant))
      api_stub_for(get: "/users/#{current_user.id}", response: from_api(current_user))
      sign_in current_user
    end

    describe '#index' do
      subject { get :index }
      context 'not admin' do
        let(:current_user) { build(:user) }
        it_behaves_like 'unauthorized access'
      end
      context 'admin' do
        context 'success' do
          before { subject }
          it 'returns a list of sub_tenant' do
            expect(response).to be_success
            expect(JSON.parse(response.body)).to eq(JSON.parse(hash_for_sub_tenants([sub_tenant]).to_json))
          end
        end
      end
    end

    describe 'GET #show' do
      subject { get :show, id: sub_tenant.id }

      before do
        api_stub_for(get: "/sub_tenants/#{sub_tenant.id}/clients", response: from_api([organization]))
        api_stub_for(get: "/sub_tenants/#{sub_tenant.id}/account_managers", response: from_api([user]))
      end
      context 'not admin' do
        let(:current_user) { build(:user) }
        it_behaves_like 'unauthorized access'
      end
      context 'admin' do
        it_behaves_like 'a jpi v1 admin action'
        context 'success' do
          before { subject }
          it 'returns a complete description of the sub_tenant' do
            expect(response).to be_success
            expect(JSON.parse(response.body)).to eq(JSON.parse(hash_for_sub_tenant(sub_tenant).to_json))
          end
        end
      end
    end

    describe 'PUT #update' do
      subject { put :update, id: sub_tenant.id, sub_tenant: {name: 'new name'} }


      before do
        api_stub_for(get: "/sub_tenants/#{sub_tenant.id}", response: from_api(sub_tenant))
        api_stub_for(put: "/sub_tenants/#{sub_tenant.id}", response: -> { sub_tenant.name = 'new name'; from_api(sub_tenant) })
        sign_in current_user
      end
      context 'not admin' do
        let(:current_user) { build(:user) }
        it_behaves_like 'unauthorized access'
      end
      it_behaves_like 'a jpi v1 admin action'
      context 'admin' do
        before { subject }
        context 'success' do
          it { expect(response).to be_success }
          # Test that the user is updated by testing the api endpoint was called
          it { expect(sub_tenant.name).to eq('new name') }
        end
      end
    end
    describe 'DELETE #destroy' do
      subject { delete :destroy, id: sub_tenant.id }
      before do
        api_stub_for(get: "/sub_tenants/#{sub_tenant.id}", response: from_api(sub_tenant))
        api_stub_for(delete: "/sub_tenants/#{sub_tenant.id}")
        sign_in current_user
      end
      it_behaves_like 'a jpi v1 admin action'

      context 'not admin' do
        let(:current_user) { build(:user) }
        it_behaves_like 'unauthorized access'
      end
      context 'admin' do
        context 'success' do
          it { subject }
        end
      end
    end
  end
end


