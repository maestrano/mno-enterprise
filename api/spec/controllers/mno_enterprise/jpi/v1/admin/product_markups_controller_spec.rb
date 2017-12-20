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

    before(:all) do
      Settings.dashboard.marketplace.provisioning = true
      Rails.application.reload_routes!
    end

    before do
      stub_api_v2(:get, "/product_markups", [product_markup], [:product, :'product.product_pricings', :organization], {})
      stub_api_v2(:get, "/product_markups/#{product_markup.id}", product_markup, [:product, :organization], {})
      stub_api_v2(:post, "/product_markups", product_markup, [], {})
      stub_api_v2(:get, "/product_markups", product_markup, [], {})
    end

    # Stub user and user call
    let(:user) { build(:user, admin_role: 'admin') }
    let!(:current_user_stub) { stub_user(user) }
    before { sign_in user }

    describe 'GET #index' do
      subject { get :index }
      it_behaves_like 'a jpi v1 admin action'

      context 'with terms' do
        subject { get :index, terms: params }
        let(:params)  { { "product.id" => product_markup.id }.to_json }
        let(:data) { JSON.parse(response.body) }

        before { stub_api_v2(:get, "/product_markups", [product_markup], [:product, :'product.product_pricings', :organization], { filter: { 'product.id' => product_markup.id } }) }

        it 'finds a markup' do
          expect(subject).to be_successful
          expect(data['product_markups'].length).to eq(1)
          expect(data['product_markups'][0]['id']).to eq(product_markup.id)
        end
      end
    end

    describe 'GET #show' do
      subject { get :show, id: product_markup.id }
      it_behaves_like 'a jpi v1 admin action'
    end

    describe 'POST #create' do
      subject { post :create, product_markup: params }
      let(:params) { { percentage: 0.11, product_id: product.id, organization_id: organization.id } }
      before { stub_audit_events }

      it_behaves_like 'a jpi v1 admin action'

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
