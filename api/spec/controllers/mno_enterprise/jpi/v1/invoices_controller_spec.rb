require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::InvoicesController, type: :controller do
    include MnoEnterprise::TestingSupport::JpiV1TestHelper

    render_views
    routes { MnoEnterprise::Engine.routes }

    # Stub controller ability
    let!(:ability) { stub_ability }
    before { allow(ability).to receive(:can?).with(any_args).and_return(true) }

    # Stub model calls
    let(:organization) { build(:organization) }
    let(:user) { build(:user, organizations: [organization]) }
    let(:invoice) {build(:invoice, organization: organization, organization_id: organization.id)}

    let!(:current_user_stub) { stub_user(user) }
    before do
      organization.orga_relations << build(:orga_relation, user_id: user.id, organization_id: organization.id, role: "Super Admin")
    end
    describe "GET #show" do
      before do
        stub_api_v2(:get, '/invoices', [invoice], [:organization], {filter:{slug:invoice.slug}, page:{number: 1, size: 1}})
      end
      before { sign_in user }
      subject { get :show, id: invoice.slug }

      it_behaves_like "a navigatable protected user action"
      it_behaves_like "a user protected resource"

      it { subject; expect(response).to be_success }
    end

    describe "GET #index" do
      before { request.env['HTTP_ACCEPT'] = 'application/json' }
      before do
        stub_api_v2(:get, "/organizations/#{organization.id}", [organization], [:orga_relations, :users])
        stub_api_v2(:get, "/invoices", [invoice], [], {filter:{'organization.id':organization.id}})
      end

      before { sign_in user }
      subject { get :index, organization_id: organization.id }

      # it_behaves_like "a navigatable protected user action"
      # it_behaves_like "a user protected resource"
      it_behaves_like "jpi v1 protected action"

      it { subject; expect(response).to be_success }
      it 'returns the correct invoices' do
        subject
        expect(assigns(:invoices).first.slug).to eq invoice.slug
      end

    end
  end

end
