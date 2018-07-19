require 'rails_helper'

module MnoEnterprise
  describe Admin::InvoicesController, type: :controller do
    include MnoEnterprise::TestingSupport::SharedExamples::JpiV1Admin

    render_views
    routes { MnoEnterprise::Engine.routes }

    #===============================================
    # Assignments
    #===============================================
    # Stub user and user call
    let(:user) { build(:user, admin_role) }
    let(:admin_role) { :admin }
    let!(:current_user_stub) { stub_user(user) }
    before { sign_in user }

    # Stub model calls
    let(:organization) { build(:organization) }
    let(:invoice) { build(:invoice, organization: organization) }
    before { stub_api_v2(:get, '/invoices', [invoice], [:organization], {filter:{slug: invoice.slug}, page:{number: 1, size: 1}}) }


    describe "GET #show" do
      subject { get :show, id: invoice.slug }

      it_behaves_like "a jpi v1 admin action"

      context 'success' do
        it 'does not authorize the org' do
          expect(response).to be_success
          expect(controller).not_to receive(:authorize!)
          subject
        end
      end

      context 'with a support role' do
        let(:admin_role) { :support }
        it 'authorizes the org' do
          expect(controller).to receive(:authorize!)
          subject
        end
      end
    end
  end
end
