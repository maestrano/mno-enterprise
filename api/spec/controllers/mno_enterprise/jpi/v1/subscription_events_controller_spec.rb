require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::SubscriptionEventsController, type: :controller do
    include MnoEnterprise::TestingSupport::JpiV1TestHelper
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

    # Stub user and user call
    let!(:user) { build(:user) }
    let!(:current_user_stub) { stub_user(user) }

    # Stub organization and association
    let!(:organization) { build(:organization) }
    let!(:orga_relation) { build(:orga_relation, role: 'Super Admin') }
    before do
      stub_orga_relation(user, organization, orga_relation)
    end

    describe 'GET #index' do
      let(:subscription) { build(:subscription) }
      let(:subscription_event) { build(:subscription_event, subscription: subscription) }

      let(:expected_params) do
        {
          filter: { 'subscription.id': subscription.id },
          _metadata: { organization_id: organization.id }
        }
      end
      before { stub_api_v2(:get, "/subscription_events", [subscription_event], [:subscription], expected_params) }
      before { sign_in user }

      subject { get :index, organization_id: organization.id, subscription_id: subscription.id }

      it_behaves_like 'jpi v1 protected action'
    end

    describe 'GET #show' do
      let(:subscription) { build(:subscription) }
      let(:subscription_event) { build(:subscription_event, subscription: subscription) }

      let(:expected_params) do
        {
          filter: { id: subscription_event.id, 'subscription.id': subscription.id },
          _metadata: { organization_id: organization.id },
          page: { number: 1, size: 1 }
        }
      end
      before { stub_api_v2(:get, "/subscription_events", subscription_event, [:subscription], expected_params) }
      before { sign_in user }

      subject { get :show, organization_id: organization.id, subscription_id: subscription.id, id: subscription_event.id }

      it_behaves_like 'jpi v1 protected action'
    end
  end
end
