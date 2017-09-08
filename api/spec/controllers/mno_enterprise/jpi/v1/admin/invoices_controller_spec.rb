require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::Admin::InvoicesController, type: :controller do
    include MnoEnterprise::TestingSupport::JpiV1TestHelper
    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env['HTTP_ACCEPT'] = 'application/json' }

    #===============================================
    # Assignments
    #===============================================
    let(:user) { build(:user, :admin) }
    let!(:current_user_stub) { stub_api_v2(:get, "/users/#{user.id}", user, %i(deletion_requests organizations orga_relations dashboards)) }

    let(:billable) { build(:app_instance) }
    let(:bill) { build(:bill) }
    let(:organization) { build(:organization) }
    let(:invoice) { build(:invoice) }

    before { sign_in user }

    describe 'GET #index' do
      subject { get :index }

      let(:data) { JSON.parse(response.body) }
      let(:select_fields) do
        {
          invoices: 'id,price,started_at,ended_at,created_at,updated_at,paid_at,slug,organization',
          organizations: 'id,name'
        }
      end

      before { allow(invoice).to receive(:bills).and_return([bill]) }
      before { allow(invoice).to receive(:organization).and_return(organization) }
      before { stub_api_v2(:get, "/invoices", [invoice], %i(organization), { fields: select_fields }) }
      before { subject }

      it { expect(data['invoices'].first['id']).to eq(invoice.id) }
    end

    describe 'GET #show' do
      subject { get :show, id: invoice.id }

      let(:data) { JSON.parse(response.body) }
      let(:select_fields) do
        {
          bills: 'id,adjustment,billing_group,end_user_price_cents,currency,description',
          invoices: 'id,price,started_at,ended_at,created_at,updated_at,paid_at,slug,tax_pips_applied,organization,bills',
          organizations: 'id,name'
        }
      end

      before { allow(invoice).to receive(:bills).and_return([bill]) }
      before { allow(invoice).to receive(:organization).and_return(organization) }
      before { stub_api_v2(:get, "/invoices/#{invoice.id}", invoice, %i(organization bills), { fields: select_fields }) }
      before { subject }

      it { expect(data['invoice']['id']).to eq(invoice.id) }
    end

    describe 'PATCH #update' do
      subject { patch :update, id: invoice.id, invoice: { paid_at: paid_at } }

      let(:paid_at) { Time.current }

      before { stub_api_v2(:get, "/invoices/#{invoice.id}", invoice, [], { fields: { invoices: 'id' } }) }
      before { stub_api_v2(:patch, "/invoices/#{invoice.id}", invoice) }

      it { is_expected.to be_successful }
    end

    describe 'POST #create_adjustment' do
      subject { post :create_adjustment, id: invoice.id, adjustment: { description: 'foo', price_cents: 20000 } }

      let(:data) { JSON.parse(response.body) }

      before { allow(invoice).to receive(:organization).and_return(organization) }
      before { stub_api_v2(:get, "/invoices/#{invoice.id}", invoice, %i(organization), { fields: { invoices: 'currency,organization', organizations: 'id' } }) }
      before { stub_api_v2(:post, "/bills", bill) }
      before { stub_api_v2(:get, "/invoices/#{invoice.id}", invoice, [], { fields: { invoices: 'price,total_due' } }) }
      before { subject }

      it { expect(data['id']).to eq(bill.id) }
      it { expect(data['invoice']['total_due']['fractional']).to eq(invoice.total_due.cents.to_f.to_s) }
      it { expect(data['invoice']['price']['fractional']).to eq(invoice.price.cents.to_f.to_s) }
    end

    describe 'DELETE #delete_adjustment' do
      subject { delete :delete_adjustment, id: invoice.id, bill_id: bill.id }

      let(:data) { JSON.parse(response.body) }

      before do
        stub_api_v2(:get, "/bills", bill, [],
          {
            fields: { bills: 'id' },
            filter: { 'adjustment' => 'true', 'invoice.id' => invoice.id, 'id' => bill.id },
            page: { number: 1, size: 1}
          })
      end
      before { stub_api_v2(:delete, "/bills/#{bill.id}") }
      before { stub_api_v2(:get, "/invoices/#{invoice.id}", invoice, [], { fields: { invoices: 'price,total_due' } }) }
      before { subject }

      it { expect(data['invoice']['total_due']['fractional']).to eq(invoice.total_due.cents.to_f.to_s) }
      it { expect(data['invoice']['price']['fractional']).to eq(invoice.price.cents.to_f.to_s) }
    end

  # TODO: re-spec reporting endpoints
  #   #===============================================
  #   # Specs
  #   #===============================================
  #   describe '#index' do
  #     subject { get :index }
  #
  #     it_behaves_like 'a jpi v1 admin action'
  #
  #     context 'success' do
  #       before { subject }
  #
  #       it 'returns a list of invoices' do
  #         expect(response).to be_success
  #         expect(JSON.parse(response.body)).to eq(JSON.parse(hash_for_invoices([invoice]).to_json))
  #       end
  #     end
  #   end
  #
  #   describe 'GET #show' do
  #     subject { get :show, id: invoice.id }
  #
  #     it_behaves_like 'a jpi v1 admin action'
  #
  #     context 'success' do
  #       before { subject }
  #
  #       it 'returns a complete description of the invoice' do
  #         expect(response).to be_success
  #         expect(JSON.parse(response.body)).to eq(JSON.parse(hash_for_invoice(invoice).to_json))
  #       end
  #     end
  #   end
  #
  #   describe 'GET #current_billing_amount' do
  #     subject { get :current_billing_amount }
  #
  #     it_behaves_like 'a jpi v1 admin action'
  #
  #     context 'with an old MnoHub' do
  #       let(:tenant) { build(:old_tenant) }
  #
  #       before { subject }
  #
  #       it { expect(response).to be_success }
  #
  #       it 'returns the sum of the current_billing' do
  #         expected =  {'current_billing_amount' => {"amount"=>"N/A", "currency"=>""}}
  #         expect(response.body).to eq(expected.to_json)
  #       end
  #     end
  #
  #     context 'success' do
  #       before { subject }
  #
  #       it { expect(response).to be_success }
  #
  #       it 'returns the sum of the current_billing' do
  #         expected =  {'current_billing_amount' => {"amount"=>"110.0", "currency"=>"AUD"}}
  #         expect(response.body).to eq(expected.to_json)
  #       end
  #     end
  #   end
  #
  #   describe 'GET #last_invoicing_amount' do
  #     subject { get :last_invoicing_amount }
  #
  #     it_behaves_like 'a jpi v1 admin action'
  #
  #     context 'success' do
  #       before { subject }
  #
  #       let(:last_invoicing_amount) { {'last_invoicing_amount' => {"amount"=>"6879.94", "currency"=>"AUD"}} }
  #
  #       it 'returns the sum of the last invoices' do
  #         expect(response).to be_success
  #         expect(JSON.parse(response.body)).to eq(JSON.parse(last_invoicing_amount.to_json))
  #       end
  #     end
  #   end
  #
  #   describe 'GET #outstanding_amount' do
  #     subject { get :outstanding_amount }
  #
  #     it_behaves_like 'a jpi v1 admin action'
  #
  #     context 'success' do
  #       before { subject }
  #       let(:outstanding_amount) { {'outstanding_amount' => {"amount"=>"1789.86", "currency"=>"AUD"}} }
  #
  #       it 'returns the sum of unpaid invoices' do
  #         expect(response).to be_success
  #         expect(JSON.parse(response.body)).to eq(JSON.parse(outstanding_amount.to_json))
  #       end
  #     end
  #   end
  #
  #   describe 'GET #last_portfolio_amount' do
  #     subject { get :last_portfolio_amount }
  #
  #     it_behaves_like 'a jpi v1 admin action'
  #
  #     context 'success' do
  #       before { subject }
  #
  #       it { expect(response).to be_success }
  #
  #       it 'returns a valid amount' do
  #         expected = {'last_portfolio_amount' => {'amount' => tenant.last_portfolio_amount.amount, 'currency' => tenant.last_portfolio_amount.currency_as_string}}
  #
  #         expect(response.body).to eq(expected.to_json)
  #       end
  #     end
  #   end
  #
  #   describe 'GET #last_commission_amount' do
  #     subject { get :last_commission_amount }
  #
  #     it_behaves_like 'a jpi v1 admin action'
  #
  #     context 'success' do
  #       before { subject }
  #       let(:last_commission_amount) { {'last_commission_amount' => {"amount"=>"4123.45", "currency"=>"AUD"}} }
  #
  #       it 'returns the sum of commissions' do
  #         expect(response).to be_success
  #         expect(JSON.parse(response.body)).to eq(JSON.parse(last_commission_amount.to_json))
  #       end
  #     end
  #   end
  end
end
