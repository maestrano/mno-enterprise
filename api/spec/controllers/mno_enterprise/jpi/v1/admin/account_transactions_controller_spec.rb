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
    let!(:organization) { build(:organization) }
    let!(:account_transaction) { build(:account_transaction) }
    let!(:user) { build(:user, :admin, organizations: [organization]) }
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

      describe 'creation' do
        context 'success' do
          before { subject }

          it 'creates the account_transaction' do
            expect(assigns(:account_transaction).amount_cents).to eq(account_transaction.amount_cents)
            expect(assigns(:account_transaction).currency).to eq(account_transaction.currency)
          end
        end
      end
    end
  end
end
