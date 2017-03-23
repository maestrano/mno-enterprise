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
    let(:user) { FactoryGirl.build(:user, :admin) }
    before { api_stub_for(get: "/users/#{user.id}", response: from_api(user)) }
    before { sign_in user }

    # Stub model calls
    let(:organization) { build(:organization) }
    let(:invoice) { build(:invoice, organization_id: organization.id) }

    # before { api_stub_for(get: "/users/#{user.id}", response: from_api(user)) }
    before { api_stub_for(get: "/organizations/#{organization.id}", response: from_api(organization)) }
    # before { api_stub_for(get: "/users/#{user.id}/organizations/#{organization.id}", response: from_api(organization)) }
    before { api_stub_for(get: "/invoices", params: { filter: { slug: '**' } }, response: from_api([invoice])) }


    describe "GET #show" do
      subject { get :show, id: invoice.slug }

      it_behaves_like "a jpi v1 admin action"

      context 'success' do
        it { subject; expect(response).to be_success }
      end
    end
  end
end
