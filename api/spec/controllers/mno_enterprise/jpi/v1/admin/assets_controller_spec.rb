require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::Admin::AssetsController, type: :controller do
    include MnoEnterprise::TestingSupport::SharedExamples::JpiV1Admin

    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env['HTTP_ACCEPT'] = 'application/json' }

    before(:all) do
      Settings.merge!(dashboard: {provisioning: {enabled: true}})
      Rails.application.reload_routes!
    end

    # Stub user and user call
    let(:user) { build(:user, admin_role: MnoEnterprise::User::ADMIN_ROLE) }
    let!(:current_user_stub) { stub_user(user) }
    before { sign_in user }

    describe 'GET #index' do
      subject { get :index }

      let(:asset) { build(:asset) }

      before { stub_api_v2(:get, '/assets', [asset], [:product], {}) }

      it_behaves_like 'a jpi v1 admin action'
    end

    describe 'GET product#index' do
      subject { get :index, product_id: product_id }

      let(:product_id) { 5 }
      let(:asset) { build(:asset) }

      before { stub_api_v2(:get, "/assets", [asset], [:product], { filter: { "product.id" => product_id } }) }

      it_behaves_like 'a jpi v1 admin action'
    end

    describe 'GET #show' do
      subject { get :show, id: asset.id }

      let(:asset) { build(:asset) }

      before { stub_api_v2(:get, "/assets/#{asset.id}", asset, [:product], {}) }

      it_behaves_like 'a jpi v1 admin action'
    end

    describe 'POST #create' do
      subject { post :create, asset: params }

      let(:params) { { content: fixture_file_upload('files/main-logo.png', 'image/png'), product_id: product_id } }
      let(:product_id) { 5 }

      before { stub_api_v2(:post, '/assets', build(:asset)) }

      it_behaves_like 'a jpi v1 admin action'
    end

    describe 'POST product#create' do
      subject { post :create, asset: params, product_id: product_id }

      let(:params) { { content: fixture_file_upload('files/main-logo.png', 'image/png') } }
      let(:product_id) { 5 }

      before { stub_api_v2(:post, '/assets', build(:asset)) }

      it_behaves_like 'a jpi v1 admin action'
    end

    describe 'DELETE #destroy' do
      subject { delete :destroy, id: asset.id }

      let(:asset) { build(:asset) }

      before { stub_api_v2(:get, "/assets/#{asset.id}", asset, [], {}) }
      before { stub_api_v2(:delete, "/assets/#{asset.id}", asset, [], {}) }

      it_behaves_like 'a jpi v1 admin action'
    end
  end
end
