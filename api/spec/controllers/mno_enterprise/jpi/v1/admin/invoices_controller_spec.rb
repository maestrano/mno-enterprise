require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::Admin::InvoicesController, type: :controller do
    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env["HTTP_ACCEPT"] = 'application/json' }

    def partial_hash_for_invoice(invoice)
      {
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
    end

    def hash_for_invoices(invoices)
      {
          'invoices' => invoices.map { |o| partial_hash_for_invoice(o) }
      }
    end

    def hash_for_invoice(invoice)
      {
          'invoice' => partial_hash_for_invoice(invoice)
      }
    end

    #===============================================
    # Assignments
    #===============================================
    # Stub invoice and invoice call
    let(:invoice) { build(:invoice) }
    let(:user) { build(:user, :admin) }
    let(:tenant) { build(:tenant, current_billing_amount: Money.new(11_000,'AUD')) }

    before do
      api_stub_for(get: "/invoices", response: from_api([invoice]))
      api_stub_for(get: "/invoices/#{invoice.id}", response: from_api(invoice))
      api_stub_for(get: "/users", response: from_api([user]))
      api_stub_for(get: "/users/#{user.id}", response: from_api(user))
      api_stub_for(get: "/tenant", response: from_api(tenant))
      sign_in user
    end

    #===============================================
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

    describe 'GET #current_billing_amount' do
      subject { get :current_billing_amount }

      context 'with an old MnoHub' do
        let(:tenant) { build(:old_tenant) }

        before { subject }

        it { expect(response).to be_success }

        it 'returns the sum of the current_billing' do
          expected =  {'current_billing_amount' => {"amount"=>"N/A", "currency"=>""}}
          expect(response.body).to eq(expected.to_json)
        end
      end

      context 'success' do
        before { subject }

        it { expect(response).to be_success }

        it 'returns the sum of the current_billing' do
          expected =  {'current_billing_amount' => {"amount"=>"110.0", "currency"=>"AUD"}}
          expect(response.body).to eq(expected.to_json)
        end
      end
    end

    describe 'GET #last_invoicing_amount' do
      subject { get :last_invoicing_amount }

      context 'success' do
        before { subject }

        let(:last_invoicing_amount) { {'last_invoicing_amount' => {"amount"=>"6879.94", "currency"=>"AUD"}} }

        it 'returns the sum of the last invoices' do
          expect(response).to be_success
          expect(JSON.parse(response.body)).to eq(JSON.parse(last_invoicing_amount.to_json))
        end
      end
    end

    describe 'GET #outstanding_amount' do
      subject { get :outstanding_amount }

      context 'success' do
        before { subject }
        let(:outstanding_amount) { {'outstanding_amount' => {"amount"=>"1789.86", "currency"=>"AUD"}} }

        it 'returns the sum of unpaid invoices' do
          expect(response).to be_success
          expect(JSON.parse(response.body)).to eq(JSON.parse(outstanding_amount.to_json))
        end
      end
    end

    describe 'GET #last_portfolio_amount' do
      subject { get :last_portfolio_amount }

      context 'success' do
        before { subject }

        it { expect(response).to be_success }

        it 'returns a valid amount' do
          expected = {'last_portfolio_amount' => {'amount' => tenant.last_portfolio_amount.amount, 'currency' => tenant.last_portfolio_amount.currency_as_string}}

          expect(response.body).to eq(expected.to_json)
        end
      end
    end

    describe 'GET #last_commission_amount' do
      subject { get :last_commission_amount }

      context 'success' do
        before { subject }
        let(:last_commission_amount) { {'last_commission_amount' => {"amount"=>"4123.45", "currency"=>"AUD"}} }

        it 'returns the sum of commissions' do
          expect(response).to be_success
          expect(JSON.parse(response.body)).to eq(JSON.parse(last_commission_amount.to_json))
        end
      end
    end
  end
end
