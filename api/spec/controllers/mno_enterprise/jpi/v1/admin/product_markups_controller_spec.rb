require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::Admin::ProductMarkupsController, type: :controller do
    include MnoEnterprise::TestingSupport::SharedExamples::JpiV1Admin
    # TODO: Fix Spec for Admin Controller
    # before { skip }

    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env['HTTP_ACCEPT'] = 'application/json' }

    let(:product_markup) { build(:product_markup) }

    before(:all) do
      Settings.merge!(dashboard: {provisioning: {enabled: true}})
      Rails.application.reload_routes!
    end

    before do
      stub_api_v2(:get, "/product_markups", [product_markup], [:product, :organization], {})
      stub_api_v2(:get, "/product_markups/#{product_markup.id}", product_markup, [:product, :organization], {})
      stub_api_v2(:post, "/product_markups/#{product_markup.id}", product_markup, [:product, :organization], {})
    end

    # Stub user and user call
    let(:user) { build(:user, admin_role: 'admin') }
    let!(:current_user_stub) { stub_api_v2(:get, "/users/#{user.id}", user, %i(deletion_requests organizations orga_relations dashboards)) }
    before do
      sign_in user
    end

    describe 'GET #index' do


      subject { get :index }

      it_behaves_like 'a jpi v1 admin action'
    end

    describe 'GET #show' do

      subject { get :show, id: product_markup.id }

      it_behaves_like 'a jpi v1 admin action'
    end

    describe 'POST #create' do
      let(:params) { FactoryGirl.attributes_for(:product_markup) }
      before { allow(MnoEnterprise::ProductMarkup).to receive(:create) { product_markup } }

      subject { post :create, product_markup: params }

      it_behaves_like 'a jpi v1 admin action'

      it 'creates the product markup' do
        expect(MnoEnterprise::ProductMarkup).to receive(:create).with(params.slice(:product_id, :organization_id)) { product_markup }
        subject
      end
    end
  end
end
