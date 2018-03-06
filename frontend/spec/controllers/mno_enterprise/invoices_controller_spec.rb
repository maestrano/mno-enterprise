require 'rails_helper'

module MnoEnterprise
  describe InvoicesController, type: :controller do
    render_views
    routes { MnoEnterprise::Engine.routes }

    # Stub controller ability
    let!(:ability) { stub_ability }
    before { allow(ability).to receive(:can?).with(any_args).and_return(true) }

    # Stub model calls
    let(:organization) { build(:organization) }
    let(:user) { build(:user, organizations: [organization]) }
    let(:invoice) {build(:invoice, organization: organization, organization_id: organization.id)}

    before do
      stub_api_v2(:get, '/invoices', [invoice], [:organization], {filter:{slug:invoice.slug}, page:{number: 1, size: 1}})
    end

    let!(:current_user_stub) { stub_user(user) }

    describe "GET #show" do
      before { sign_in user }
      subject { get :show, id: invoice.slug }

      it_behaves_like "a navigatable protected user action"
      it_behaves_like "a user protected resource"

      it { subject; expect(response).to be_success }
    end

  end

end
