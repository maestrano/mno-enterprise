require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::Admin::QuotesController, type: :controller do
    include MnoEnterprise::TestingSupport::SharedExamples::JpiV1Admin

    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env['HTTP_ACCEPT'] = 'application/json' }

    before(:all) do
      Settings.merge!(dashboard: {marketplace: {provisioning: true}})
      Rails.application.reload_routes!
    end

    # Stub controller ability
    let!(:ability) { stub_ability }
    before { allow(ability).to receive(:can?).with(any_args).and_return(true) }
    let!(:user) { build(:user, :admin) }
    let!(:current_user_stub) { stub_user(user) }

    let!(:organization) { build(:organization, orga_relations: []) }
    let!(:orga_relation) { organization.orga_relations << build(:orga_relation, user_id: user.id, organization_id: organization.id, role: 'Super Admin') }
    let!(:organization_stub) { stub_api_v2(:get, "/organizations/#{organization.id}", organization, %i(orga_relations users)) }

    let!(:quote) { build(:product_quote) }
    let(:params) { { 'foo' => 'bar' } }

    before { sign_in user }

    describe 'POST #create' do
      let!(:stub) { stub_api_v2(:post, '/product_quotes', quote) }
      subject { post :create, organization_id: organization.id, params: params }

      context 'success' do
        it_behaves_like 'a jpi v1 admin action'

        it 'Fetches the Product Quote' do
          subject
          expect(JSON.parse(response.body)['quote']).to eq(quote.quote)
        end

        it 'renders the :show view' do
          subject
          expect(response).to render_template :show
        end

        it 'Requests a quote from hub.' do
          subject
          expect(stub).to have_been_requested
        end
      end
    end
  end
end
