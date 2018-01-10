require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::Admin::SubTenantsController, type: :controller do
    include MnoEnterprise::TestingSupport::SharedExamples::JpiV1Admin
    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env['HTTP_ACCEPT'] = 'application/json' }

    def hash_for_sub_tenants(sub_tenants)
      {
        'sub_tenants' => sub_tenants.map { |s| partial_hash_for_sub_tenant(s) }
      }
    end

    def hash_for_sub_tenant(s)
      { 'sub_tenant' => partial_hash_for_sub_tenant(s) }
    end

    def partial_hash_for_sub_tenant(s)
      {
        'id' => s.id,
        'name' => s.name,
        'created_at' => s.created_at,
        'updated_at' => s.updated_at
      }
    end

    #===============================================
    # Specs
    #===============================================
    let!(:user) { build(:user, :admin) }
    let(:sub_tenant) { build(:sub_tenant) }
    let!(:current_user_stub) { stub_user(user) }

    describe '#index' do
      subject { get :index }

      before { stub_api_v2(:get, "/sub_tenants", [sub_tenant]) }

      it_behaves_like 'a jpi v1 admin action'

      context 'success' do
        before { sign_in user }

        it 'returns a list of sub_tenant' do
          expect(JSON.parse(subject.body)).to eq(JSON.parse(hash_for_sub_tenants([sub_tenant]).to_json))
        end
      end
    end

    describe 'GET #show' do
      subject { get :show, id: sub_tenant.id }

      before { stub_api_v2(:get, "/sub_tenants/#{sub_tenant.id}", sub_tenant) }

      it_behaves_like 'a jpi v1 admin action'

      context 'success' do
        before { sign_in user }
        it 'returns a complete description of the sub_tenant' do
          expect(response).to be_success
          expect(JSON.parse(subject.body)).to eq(JSON.parse(hash_for_sub_tenant(sub_tenant).to_json))
        end
      end
    end

    describe 'PUT #update' do
      subject { put :update, id: sub_tenant.id, sub_tenant: { name: 'new name' } }

      before { stub_api_v2(:get, "/sub_tenants/#{sub_tenant.id}", sub_tenant) }
      let!(:stub) { stub_api_v2(:patch, "/sub_tenants/#{sub_tenant.id}", sub_tenant) }

      it_behaves_like 'a jpi v1 admin action'

      context 'success' do
        before { sign_in user }
        before { subject }
        it { expect(response).to be_success }
        it { expect(stub).to have_been_requested }
      end
    end

    describe 'PATCH #update_clients' do
      subject { put :update_clients, id: sub_tenant.id, sub_tenant: { add: [] } }

      before { stub_api_v2(:get, "/sub_tenants/#{sub_tenant.id}", sub_tenant) }
      let!(:stub) { stub_api_v2(:patch, "/sub_tenants/#{sub_tenant.id}/update_clients", sub_tenant) }

      it_behaves_like 'a jpi v1 admin action'

      context 'success' do
        before { sign_in user }
        before { subject }
        it { expect(response).to be_success }
        it { expect(stub).to have_been_requested }
      end
    end

    describe 'PATCH #update_account_managers' do
      subject { put :update_account_managers, id: sub_tenant.id, sub_tenant: { add: [] } }

      before { stub_api_v2(:get, "/sub_tenants/#{sub_tenant.id}", sub_tenant) }
      let!(:stub) { stub_api_v2(:patch, "/sub_tenants/#{sub_tenant.id}/update_account_managers", sub_tenant) }

      it_behaves_like 'a jpi v1 admin action'

      context 'success' do
        before { sign_in user }
        before { subject }
        it { expect(response).to be_success }
        it { expect(stub).to have_been_requested }
      end
    end

    describe 'DELETE #destroy' do
      subject { delete :destroy, id: sub_tenant.id }

      before { stub_api_v2(:get, "/sub_tenants/#{sub_tenant.id}", sub_tenant) }
      let!(:stub) { stub_api_v2(:delete, "/sub_tenants/#{sub_tenant.id}", sub_tenant) }

      it_behaves_like 'a jpi v1 admin action'

      context 'success' do
        before { sign_in user  }
        before { subject }
        it { expect(response).to be_success }
        it { expect(stub).to have_been_requested }
      end
    end
  end
end
