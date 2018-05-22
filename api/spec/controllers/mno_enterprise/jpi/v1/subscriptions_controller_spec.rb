require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::SubscriptionsController, type: :controller do
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
    let!(:organization) { build(:organization, orga_relations: []) }
    let!(:orga_relation) { organization.orga_relations << build(:orga_relation, user_id: user.id, organization_id: organization.id, role: 'Super Admin') }
    let!(:organization_stub) { stub_api_v2(:get, "/organizations/#{organization.id}", organization, %i(orga_relations users)) }

    # Stub license_assignments association
    before { allow_any_instance_of(MnoEnterprise::Subscription).to receive(:license_assignments).and_return([]) }

    describe 'GET #index' do
      let(:subscription) { build(:subscription) }

      before { stub_api_v2(:get, "/subscriptions", [subscription], [:'product_pricing.product', :product, :product_contract, :organization, :user, :'license_assignments.user', :'product_instance.product'], {filter: {organization_id: organization.id}, '_metadata[organization_id]' => organization.id}) }
      before { sign_in user }

      subject { get :index, organization_id: organization.id }

      it_behaves_like 'jpi v1 protected action'
    end

    describe 'GET #show' do
      let(:subscription) { build(:subscription) }

      before { stub_api_v2(:get, "/subscriptions", subscription, [:'product_pricing.product', :product, :product_contract, :organization, :user, :'license_assignments.user', :'product_instance.product'], {filter: {organization_id: organization.id, id: subscription.id, subscription_status_in: 'visible'}, 'page[number]' => 1, 'page[size]' => 1, '_metadata[organization_id]' => organization.id}) }
      before { sign_in user }

      subject { get :show, organization_id: organization.id, id: subscription.id }

      it_behaves_like 'jpi v1 protected action'
    end

    describe 'POST #create' do
      let(:subscription) { build(:subscription, status: :provisioning) }
      let(:product) { build(:product) }
      let(:product_pricing) { build(:product_pricing, product: product) }

      before { stub_audit_events }
      before { stub_api_v2(:post, "/subscriptions", subscription, [], {}) }

      context 'staged subscription' do
        before { stub_api_v2(:get, "/subscriptions", subscription, [:'product_pricing.product', :product, :product_contract, :organization, :user, :'license_assignments.user', :'product_instance.product'], {filter: {organization_id: organization.id, id: subscription.id, subscription_status_in: 'staged'}, 'page[number]' => 1, 'page[size]' => 1, '_metadata[organization_id]' => organization.id}) }
        before { sign_in user }

        subject { post :create, organization_id: organization.id, subscription: {custom_data: {foo: :bar}.to_json, product_pricing_id: product_pricing.id, cart_entry: true} }

        it_behaves_like 'jpi v1 protected action'

        it 'passes the correct parameters' do
          expect(subject).to be_successful
          assert_requested_api_v2(:post, '/subscriptions',
                                   body: {
                                    "data" => {
                                      "type" => "subscriptions",
                                      "relationships" => {
                                        "organization" => {"data" => {"type" => "organizations", "id" => organization.id}},
                                        "user" => {"data" => {"type" => "users", "id" => user.id}},
                                        "product_pricing" => {"data" => {"type" => "product_pricings", "id" => product_pricing.id}}
                                      },
                                      "attributes" => {
                                        "product_pricing_id" => product_pricing.id,
                                        "custom_data" => {"foo" => "bar"}.to_json,
                                        "status" => "staged"}
                                      }
                                    }.to_json)
        end
      end

      context 'normal subscription' do
        before { stub_api_v2(:get, "/subscriptions", subscription, [:'product_pricing.product', :product, :product_contract, :organization, :user, :'license_assignments.user', :'product_instance.product'], {filter: {organization_id: organization.id, id: subscription.id, subscription_status_in: 'visible'}, 'page[number]' => 1, 'page[size]' => 1, '_metadata[organization_id]' => organization.id}) }
        before { sign_in user }

        subject { post :create, organization_id: organization.id, subscription: {custom_data: {foo: :bar}.to_json, product_pricing_id: product_pricing.id, cart_entry: false} }

        it_behaves_like 'jpi v1 protected action'

        it 'passes the correct parameters' do
          expect(subject).to be_successful
          assert_requested_api_v2(:post, '/subscriptions',
                                   body: {
                                    "data" => {
                                      "type" => "subscriptions",
                                      "relationships" => {
                                        "organization" => {
                                          "data" => {
                                            "type" => "organizations",
                                            "id" => organization.id
                                            }
                                          },
                                        "user" => {"data" => {"type" => "users", "id" => user.id}},
                                        "product_pricing" => {"data" => {"type" => "product_pricings", "id" => product_pricing.id}}
                                      },
                                      "attributes" => {
                                        "product_pricing_id" => product_pricing.id,
                                        "custom_data" => {"foo" => "bar"}.to_json}
                                      }
                                    }.to_json)
        end
      end
    end

    describe 'PUT #update' do
      let(:subscription) { build(:subscription) }
      let(:product) { build(:product) }
      let(:product_pricing) { build(:product_pricing, product: product) }
      let(:edit_action) { "change" }

      before { stub_audit_events }
      before { stub_api_v2(:post, "/subscriptions/#{subscription.id}/#{edit_action}", subscription, [], {}) }
      before { stub_api_v2(:get, "/subscriptions", subscription, [], {filter: {organization_id: organization.id, id: subscription.id}, 'page[number]' => 1, 'page[size]' => 1}) }
      before { stub_api_v2(:get, "/subscriptions", subscription, [:'product_pricing.product', :product, :product_contract, :organization, :user, :'license_assignments.user', :'product_instance.product'], {filter: {organization_id: organization.id, id: subscription.id, subscription_status_in: 'visible'}, 'page[number]' => 1, 'page[size]' => 1, '_metadata[organization_id]' => organization.id}) }
      before { sign_in user }

      subject { put :update, organization_id: organization.id, id: subscription.id, subscription: {custom_data: {foo: :bar}.to_json, product_pricing_id: product_pricing.id, edit_action: edit_action }}

      it_behaves_like 'jpi v1 protected action'

      it 'passes the correct parameters' do
        expect(subject).to be_successful
        assert_requested_api_v2(:post, "/subscriptions/#{subscription.id}/#{edit_action}",
                                 body: {
                                  "data" => {
                                    "id" => subscription.id,
                                    "type" => "subscriptions",
                                    "attributes" => {
                                      "product_pricing_id" => product_pricing.id,
                                      "custom_data" => {"foo" => "bar"}.to_json}
                                    },
                                  }.to_json)
      end
    end
  end
end
