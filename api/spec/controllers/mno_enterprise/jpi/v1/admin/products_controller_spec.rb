require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::Admin::ProductsController, type: :controller do
    include MnoEnterprise::TestingSupport::SharedExamples::JpiV1Admin

    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env['HTTP_ACCEPT'] = 'application/json' }

    before(:all) do
      Settings.merge!(dashboard: {marketplace: {local_products: true}})
      Rails.application.reload_routes!
    end

    # Stub user and user call
    let(:user) { build(:user, admin_role: MnoEnterprise::User::ADMIN_ROLE) }
    let!(:current_user_stub) { stub_user(user) }
    before do
      sign_in user
    end

    describe 'GET #index' do
      subject { get :index }
      let(:product) { build(:product) }
      before { stub_api_v2(:get, '/products', [product], [:'values.field', :assets, :categories, :product_pricings, :product_contracts]) }

      it_behaves_like 'a jpi v1 admin action'
      it_behaves_like 'an unauthorized route for support users'
    end

    describe 'GET #show' do
      subject { get :show, id: product.id }
      let(:product) { build(:product) }
      before { stub_api_v2(:get, "/products/#{product.id}", product, [:'values.field', :assets, :categories, :product_pricings, :product_contracts]) }

      it_behaves_like 'a jpi v1 admin action'
      it_behaves_like 'an unauthorized route for support users'
    end

    describe 'GET #custom_schema' do
      subject { get :custom_schema, id: product.id, editAction: 'SUSPEND' }
      let(:product) { build(:product) }
      before { stub_api_v2(:get, "/products/#{product.id}", product, [], { _fetch_custom_schema: true, _edit_action: 'SUSPEND', fields: { products: 'custom_schema' } }) }

      it_behaves_like 'a jpi v1 admin action'
      it_behaves_like 'an authorized route for support users'
    end
  end
end
