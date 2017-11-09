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
    let(:user) { build(:user, :admin) }
    let!(:current_user_stub) { stub_user(user) }
    before { sign_in user }

    # Stub model calls
    let(:organization) { build(:organization) }
    let(:invoice) { build(:invoice, organization: organization) }
    before { allow(invoice).to receive(:organization).and_return(organization) }
    before {stub_api_v2(:get, '/invoices', [invoice], [:organization], {filter:{slug: invoice.slug}, page:{number: 1, size: 1}})}


    describe "GET #show" do
      subject { get :show, id: invoice.slug }

      it_behaves_like "a jpi v1 admin action"

      context 'success' do
        it { subject; expect(response).to be_success }
      end
    end
  end
end
