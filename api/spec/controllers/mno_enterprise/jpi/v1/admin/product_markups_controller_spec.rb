require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::Admin::ProductMarkupsController, type: :controller do
    include MnoEnterprise::TestingSupport::SharedExamples::JpiV1Admin

    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env['HTTP_ACCEPT'] = 'application/json' }

    let(:organization) { build(:organization) }
    let(:product) { build(:product) }
    let(:product_pricing) { build(:product_pricing, product: product) }
    let(:product_markup) { build(:product_markup, organization: organization, product: product ) }
    let(:expected_params) { { _metadata: { act_as_manager: user.id } } }

    before(:all) do
      Settings.merge!(dashboard: {provisioning: {enabled: true}})
      Rails.application.reload_routes!
    end

    before do
      stub_api_v2(:get, "/product_markups", [product_markup], [:product, :'product.product_pricings', :organization], expected_params)
      stub_api_v2(:get, "/product_markups/#{product_markup.id}", product_markup, [:product, :organization], expected_params)
      stub_api_v2(:post, "/product_markups", product_markup, [], {})
      stub_api_v2(:get, "/product_markups", product_markup, [], expected_params)
    end

    # Stub user and user call
    let(:user) { build(:user, admin_role: admin_role) }
    let(:admin_role) { MnoEnterprise::User::ADMIN_ROLE }
    let!(:current_user_stub) { stub_user(user) }
    before { sign_in user }

    describe 'GET #index' do
      subject { get :index, params }
      let(:params)  { { 'terms'=> { "product.id" => product_markup.id }.to_json } }
      let(:data) { JSON.parse(response.body) }
      let(:stub_get_params) { { filter: { 'product.id' => product_markup.id }, '_metadata' => { 'act_as_manager'=> user.id } } }
      before { stub_api_v2(:get, "/product_markups", [product_markup], [:product, :'product.product_pricings', :organization], stub_get_params) }

      it_behaves_like 'a jpi v1 admin action'

      context 'with terms' do
        it 'finds a markup' do
          expect(subject).to be_successful
          expect(data['product_markups'].length).to eq(1)
          expect(data['product_markups'][0]['id']).to eq(product_markup.id)
        end
      end

      context 'with a support user' do
        subject { get :index, params }
        let(:filter) { { filter: { 'product.id' => product_markup.id,  } } }
        let(:admin_role) { MnoEnterprise::User::SUPPORT_ROLE }
        let(:params) { {} }
        before { stub_api_v2(:get, "/product_markups", [product_markup], [:product, :'product.product_pricings', :organization], stub_get_params) }

        context 'with organization parameters' do
          let(:params)  { { "where" => { "for_organization" => orgId } } }
          let(:stub_get_params) { { filter: { 'for_organization' => orgId }, '_metadata' => { 'act_as_manager'=> user.id } } }
          let(:orgId) { "1" }
          it 'authorizes the correct organization' do
            expect(controller).to receive(:authorize!).with(:read, MnoEnterprise::Organization.new(id: orgId))
            subject
          end
        end

        context 'without organization parameters' do
          it_behaves_like 'an unauthorized route for support users'
        end
      end
    end

    describe 'GET #show' do
      subject { get :show, id: product_markup.id }
      it_behaves_like 'a jpi v1 admin action'
      it_behaves_like 'an unauthorized route for support users'
    end

    describe 'POST #create' do
      subject { post :create, product_markup: params }
      let(:params) { { percentage: 0.11, product_id: product.id, organization_id: organization.id } }
      before { stub_audit_events }

      it_behaves_like 'a jpi v1 admin action'
      it_behaves_like 'an unauthorized route for support users'

      it 'passes the correct parameters' do
        expect(subject).to be_successful
        assert_requested_api_v2(:post, '/product_markups',
                                body: {
                                  "data" => {
                                    "type" => "product_markups",
                                    "relationships" => {
                                      "product" => {"data" => {"type" => "products", "id" => product.id } },
                                      "organization" => {"data" => {"type" => "organizations", "id" => organization.id } }
                                    },
                                    "attributes" => {"percentage" => "0.11" } }
                                }.to_json)
      end

    end
  end
end
