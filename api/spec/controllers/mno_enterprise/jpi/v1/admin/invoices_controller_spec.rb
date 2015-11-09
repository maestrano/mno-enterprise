require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::Admin::InvoicesController, type: :controller do
    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env["HTTP_ACCEPT"] = 'application/json' }

    def partial_hash_for_invoice(invoice)
      ret = {
          'id' => invoice.id,
          'price' => invoice.price,
          'started_at' => invoice.started_at,
          'ended_at' => invoice.ended_at,
          'created_at' => invoice.created_at,
          'updated_at' => invoice.updated_at,
          'paid_at' => invoice.paid_at,
          'slug' => invoice.slug,
          'tax_pips_applied' => invoice.tax_pips_applied,
          'billing_address' => invoice.billing_address
      }
      return ret
    end

    def hash_for_invoices(invoices)
      {
          'invoices' => invoices.map { |o| partial_hash_for_invoice(o) }
      }
    end

    def hash_for_invoice(invoice)
      hash = {
          'invoice' => partial_hash_for_invoice(invoice)
      }

      return hash
    end

    #===============================================
    # Assignments
    #===============================================
    # Stub controller ability
    # let!(:ability) { stub_ability }
    # before { allow(ability).to receive(:can?).with(any_args).and_return(true) }

    # Stub invoice and invoice call
    let(:invoice) { build(:invoice, :admin) }
    before do
      api_stub_for(get: "/invoices", response: from_api([invoice]))
      # api_stub_for(put: "/invoices/#{invoice.id}", response: from_api(invoice))
      api_stub_for(get: "/invoices/#{invoice.id}", response: from_api(invoice))
      sign_in invoice
    end

    #==========================
    # =====================
    # Specs
    #===============================================
    describe '#index' do
      subject { get :index }

      context 'success' do
        before { subject }

        it 'returns a list of invoices' do
          expect(response).to be_success
          expect(JSON.parse(response.body)).to eq(JSON.parse(hash_for_invoices([invoice]).to_json))
        end
      end
    end

    describe 'GET #show' do
      subject { get :show, id: invoice.id }

      context 'success' do
        before { subject }

        it 'returns a complete description of the invoice' do
          expect(response).to be_success
          expect(JSON.parse(response.body)).to eq(JSON.parse(hash_for_invoice(invoice).to_json))
        end
      end
    end
  end
end