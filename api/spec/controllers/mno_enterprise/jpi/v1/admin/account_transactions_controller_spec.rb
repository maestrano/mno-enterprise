require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::Admin::AccountTransactionsController, type: :controller do
    include MnoEnterprise::TestingSupport::SharedExamples::JpiV1Admin

    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env["HTTP_ACCEPT"] = 'application/json' }

    #===============================================
    # Assignments
    #===============================================
    let(:tenant) { build(:tenant)}
    let!(:organization) { build(:organization, mnoe_tenant: tenant) }
    let!(:account_transaction) { build(:account_transaction) }
    let!(:user) { build(:user, :admin, organizations: [organization], mnoe_tenant: tenant) }
    let!(:organization_stub) { stub_api_v2(:get, "/organizations/#{organization.id}", organization, []) }
    let!(:current_user_stub) { stub_user(user) }

    #===============================================
    # Specs
    #===============================================
    before { sign_in user }

    describe 'POST #create' do
      let(:params) { {currency: "AUD", ammount_cents: 1200, side: "credit", description: "Test description", organization_id: organization.id } }

      subject { post :create, account_transaction: params }

      before { stub_api_v2(:post, '/account_transactions', account_transaction) }
      before { stub_api_v2(:get, "/organizations/#{organization.id}", organization, []) }
      before { stub_audit_events }

      describe 'creation' do
        context 'success' do
          before { stub_api_v2(:get, '/tenant', tenant) }
          before { subject }

          let(:data) { JSON.parse(response.body) }
          it 'creates the account_transaction' do
            expect(data['attributes']['currency']).to eq(account_transaction.currency)
            expect(data['attributes']['amount_cents']).to eq(account_transaction.amount_cents)
          end
        end

        context 'Tenant feature flag not active' do
          before { tenant.metadata[:can_manage_organization_credit] = false }
          before { stub_api_v2(:get, '/tenant', tenant) }
          before { subject }

          it "does not create the account_transaction" do
            expect(response.body).to be_blank
            expect(response).to have_http_status(:forbidden)
          end
        end
      end
    end
  end
end
