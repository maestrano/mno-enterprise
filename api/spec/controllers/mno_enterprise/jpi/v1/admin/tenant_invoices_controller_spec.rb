require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::Admin::TenantInvoicesController, type: :controller do
    include MnoEnterprise::TestingSupport::SharedExamples::JpiV1Admin

    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env['HTTP_ACCEPT'] = 'application/json' }

    def partial_hash_for_tenant_invoices(tenant_invoice)
      {
          'id' => tenant_invoice.id,
          'started_at' => tenant_invoice.started_at,
          'ended_at' => tenant_invoice.ended_at,
          'created_at' => tenant_invoice.created_at,
          'updated_at' => tenant_invoice.updated_at,
          'slug' => tenant_invoice.slug,
          'paid_at' => tenant_invoice.paid_at,
          'total_portfolio_amount' => AccountingjsSerializer.serialize(tenant_invoice.total_portfolio_amount),
          'total_commission_amount' => AccountingjsSerializer.serialize(tenant_invoice.total_commission_amount),
          'non_commissionable_amount' => AccountingjsSerializer.serialize(tenant_invoice.non_commissionable_amount)
      }
    end

    def partial_hash_for_tenant_invoice(tenant_invoice)
      {
          'id' => tenant_invoice.id,
          'started_at' => tenant_invoice.started_at,
          'created_at' => tenant_invoice.created_at,
          'ended_at' => tenant_invoice.ended_at,
          'updated_at' => tenant_invoice.updated_at,
          'paid_at' => tenant_invoice.paid_at,
          'slug' => tenant_invoice.slug
      }
    end

    def hash_for_tenant_invoices(tenant_invoices)
      {
          'tenant_invoices' => tenant_invoices.map { |o| partial_hash_for_tenant_invoices(o) }
      }

    end

    def hash_for_tenant_invoice(tenant_invoice)
      {
          'tenant_invoice' => partial_hash_for_tenant_invoice(tenant_invoice)
      }
    end

    #===============================================
    # Assignments
    #===============================================
    # Stub tenant_invoice and tenant_invoice call
    let!(:tenant_invoice) { build(:tenant_invoice) }
    let!(:user) { build(:user, :admin) }
    let!(:current_user_stub) { stub_user(user) }

    before do
      stub_api_v2(:get, "/tenant_invoices", [tenant_invoice])
      stub_api_v2(:get, "/tenant_invoices/#{tenant_invoice.id}", tenant_invoice)
      sign_in user
    end

    #===============================================
    # Specs
    #===============================================
    describe '#index' do
      subject { get :index }

      it_behaves_like 'a jpi v1 admin action'
      context 'success' do
        before { subject }
        it 'returns a list of tenant_invoices' do
          expect(response).to be_success
          expect(JSON.parse(response.body)).to eq(JSON.parse(hash_for_tenant_invoices([tenant_invoice]).to_json))
        end
      end
    end

    describe 'GET #show' do
      subject { get :show, id: tenant_invoice.id }

      it_behaves_like 'a jpi v1 admin action'
      context 'success' do
        before { subject }

        it 'returns a complete description of the tenant_invoice' do
          expect(response).to be_success
          expect(JSON.parse(response.body)).to eq(JSON.parse(hash_for_tenant_invoice(tenant_invoice).to_json))
        end
      end
    end
  end
end
