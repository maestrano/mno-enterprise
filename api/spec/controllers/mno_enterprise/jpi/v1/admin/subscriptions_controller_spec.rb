require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::Admin::SubscriptionsController, type: :controller do
    include MnoEnterprise::TestingSupport::SharedExamples::JpiV1Admin

    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env["HTTP_ACCEPT"] = 'application/json' }

    before(:each) do
      Settings.merge!(dashboard: { marketplace: {provisioning: true } })
      Rails.application.reload_routes!
    end

    #===============================================
    # Assignments
    #===============================================
    let(:user) { build(:user, :admin) }
    let!(:current_user_stub) { stub_user(user) }

    let(:organization) { build(:organization) }
    let(:subscription) { build(:subscription) }

    #===============================================
    # Specs
    #===============================================
    before { sign_in user }

    describe 'GET #index' do
      subject { get :index }

      let(:data) { JSON.parse(response.body) }
      let(:includes) { [:'product_pricing.product', :product, :product_contract, :organization, :user, :'license_assignments.user', :'product_instance.product'] }
      let(:expected_params) { { _metadata: { act_as_manager: user.id } } }

      before { allow(subscription).to receive(:license_assignments).and_return([]) }
      before { stub_api_v2(:get, "/subscriptions", [subscription], includes, expected_params) }
      before { subject }

      it { expect(data['subscriptions'].first['id']).to eq(subscription.id) }
    end

    describe 'GET #show' do
      subject { get :show, id: subscription.id, organization_id: organization.id }

      let(:data) { JSON.parse(response.body) }
      let(:includes) { [:'product_pricing.product', :product, :product_contract, :organization, :user, :'license_assignments.user', :'product_instance.product'] }
      let(:expected_params) do
        {
          filter: { id: subscription.id, organization_id: organization.id, subscription_status_in: 'visible' },
          _metadata: { act_as_manager: user.id },
          page: { number: 1, size: 1 } }
      end

      before { allow(subscription).to receive(:license_assignments).and_return([]) }
      before { allow(subscription).to receive(:organization).and_return(organization) }
      before { stub_api_v2(:get, "/subscriptions", subscription, includes, expected_params) }
      before { subject }

      it { expect(data['subscription']['id']).to eq(subscription.id) }
    end
  end
end
