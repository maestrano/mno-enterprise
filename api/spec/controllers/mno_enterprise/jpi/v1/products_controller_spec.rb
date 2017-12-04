require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::ProductsController, type: :controller do
    include MnoEnterprise::TestingSupport::JpiV1TestHelper
    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env['HTTP_ACCEPT'] = 'application/json' }

    before(:all) do
      Settings.merge!(dashboard: { marketplace: { local_products: true } })
      Rails.application.reload_routes!
    end

    # Stub user and user call
    let!(:user) { build(:user) }
    let(:organization) { build(:organization) }
    let!(:current_user_stub) { stub_user(user) }
    before do
      stub_orga_relation(user, organization, build(:orga_relation))
    end

    describe 'GET #index' do
      subject { get :index, params }

      let(:params) { {} }
      let(:product) { build(:product) }

      before { sign_in user }

      context 'without organization_id' do
        before { stub_api_v2(:get, "/products", [product], [:'values.field', :assets, :categories, :product_pricings, :product_contracts], { filter: { active: true } }) }
        it_behaves_like 'jpi v1 protected action'
      end

      context 'with organization_id' do
        let(:params) { { organization_id: organization.id } }

        before { stub_api_v2(:get, "/organizations/#{organization.id}", organization, %i(orga_relations users)) }
        before do
          stub_api_v2(:get, "/products", [product],
                      [:'values.field', :assets, :categories, :product_pricings, :product_contracts], { filter: { active: true }, _metadata: { organization_id: organization.id } })
        end

        it_behaves_like 'jpi v1 protected action'
      end
    end

    describe 'GET #show' do
      let(:product) { build(:product) }

      before { stub_api_v2(:get, "/products/#{product.id}", product, [:'values.field', :assets, :categories, :product_pricings, :product_contracts], {}) }
      before { sign_in user }

      subject { get :show, id: product.id }

      it_behaves_like 'jpi v1 protected action'
    end
  end
end
