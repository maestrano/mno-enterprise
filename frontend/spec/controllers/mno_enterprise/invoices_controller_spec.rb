require 'rails_helper'

module MnoEnterprise
  describe InvoicesController, type: :controller do
    render_views
    routes { MnoEnterprise::Engine.routes }

    # Stub controller ability
    let!(:ability) { stub_ability }
    before { allow(ability).to receive(:can?).with(any_args).and_return(true) }

    # Stub model calls
    let(:user) { build(:user) }
    let(:organization) { build(:organization) }
    let(:invoice) { build(:invoice, organization_id: organization.id) }
    before { api_stub_for(get: "/users/#{user.id}", response: from_api(user)) }
    before { api_stub_for(get: "/organizations/#{organization.id}", response: from_api(organization)) }
    before { api_stub_for(get: "/users/#{user.id}/organizations/#{organization.id}", response: from_api(organization)) }
    before { api_stub_for(get: "/invoices", params: { filter: { slug: '**' } }, response: from_api([invoice])) }


    describe "GET #show" do
      before { sign_in user }
      subject { get :show, id: invoice.slug }

      it_behaves_like "a navigatable protected user action"
      it_behaves_like "a user protected resource"

      it { subject; expect(response).to be_success }
    end

  end

end
