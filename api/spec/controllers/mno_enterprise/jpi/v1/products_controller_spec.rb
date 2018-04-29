require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::ProductsController, type: :controller do
    include MnoEnterprise::TestingSupport::JpiV1TestHelper
    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env['HTTP_ACCEPT'] = 'application/json' }

    before(:all) do
      Settings.merge!(dashboard: {marketplace: {local_products: true}})
      Rails.application.reload_routes!
    end

    # Stub user and user call
    let!(:user) { build(:user) }
    let!(:current_user_stub) { stub_user(user) }

    describe 'GET #index' do
      subject { get :index, params }

      let(:params) { {} }
      let(:product) { build(:product) }
      let(:organization) {
        o = build(:organization, orga_relations: [])
        o.orga_relations << build(:orga_relation, user_id: user.id, organization_id: o.id, role: 'Super Admin')
        o
      }

      before { sign_in user }

      context 'without organization_id' do
        before { stub_api_v2(:get, "/products", [product], [:'values.field', :assets, :categories, :product_contracts], { filter: { active: true } }) }
        it_behaves_like 'jpi v1 protected action'
      end

      context 'with organization_id' do
        let(:params) { { organization_id: organization.id } }

        before { stub_api_v2(:get, "/organizations/#{organization.id}", organization, %i(orga_relations users)) }
        before do
          stub_api_v2(:get, "/products", [product],
            [:'values.field', :assets, :categories, :product_contracts], { filter: { active: true }, _metadata: { organization_id: organization.id } })
        end

        it_behaves_like 'jpi v1 protected action'
      end
    end

    describe 'GET #show' do
      let(:product) { build(:product) }

      before { stub_api_v2(:get, "/products/#{product.id}", product, [:'values.field', :assets, :categories, :product_contracts]) }
      before { sign_in user }

      subject { get :show, id: product.id}

      it_behaves_like 'jpi v1 protected action'
    end

    describe 'GET #custom_schema' do
      let(:product) { build(:product) }

      before { stub_api_v2(:get, "/products/#{product.id}", product, [], { _fetch_custom_schema: true, _edit_action: 'SUSPEND', fields: { products: 'custom_schema' } }) }
      before { sign_in user }

      subject { get :custom_schema, id: product.id, editAction: 'SUSPEND' }

      it_behaves_like 'jpi v1 protected action'
    end
  end
end
