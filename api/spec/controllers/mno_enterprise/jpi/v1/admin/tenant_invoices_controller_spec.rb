require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::Admin::TenantInvoicesController, type: :controller do
    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env["HTTP_ACCEPT"] = 'application/json' }

    def partial_hash_for_tenant_invoice(tenant_invoice)
      ret = {
          'started_at' => tenant_invoice.started_at,
          'ended_at' => tenant_invoice.ended_at,
          'mnoe_tenant' => tenant_invoice.mnoe_tenant,
          'tax' => tenant_invoice.tax,
          'commission' => tenant_invoice.commission,
          'total_portfolio_amount' => tenant_invoice.total_portfolio_amount,
          'total_commission_amount' => tenant_invoice.total_commission_amount,
          'non_commissionable_amount' => tenant_invoice.non_commissionable_amount,
          'mno_commission_amount' => tenant_invoice.mno_commission_amount
      }
      return ret
    end

    def hash_for_tenant_invoices(tenant_invoices)
      {
          'tenant_invoices' => tenant_invoices.map { |o| partial_hash_for_tenant_invoice(o) }
      }
    end

    def hash_for_tenant_invoice(tenant_invoice)
      hash = {
          'tenant_invoice' => partial_hash_for_tenant_invoice(tenant_invoice)
      }

      return hash
    end

    #===============================================
    # Assignments
    #===============================================
    # Stub controller ability
    # let!(:ability) { stub_ability }
    # before { allow(ability).to receive(:can?).with(any_args).and_return(true) }

    # Stub tenant_invoice and tenant_invoice call
    let(:tenant_invoice) { build(:tenant_invoice, :admin) }
    before do
      api_stub_for(get: "/tenant_invoices", response: from_api([tenant_invoice]))
      # api_stub_for(put: "/tenant_invoices/#{tenant_invoice.id}", response: from_api(tenant_invoice))
      api_stub_for(get: "/tenant_invoices/#{tenant_invoice.id}", response: from_api(tenant_invoice))
      sign_in tenant_invoice
    end

    #==========================
    # =====================
    # Specs
    #===============================================
    describe '#index' do
      subject { get :index }

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