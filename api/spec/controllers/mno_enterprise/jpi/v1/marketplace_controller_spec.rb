require 'rails_helper'

module MnoEnterprise
  describe MnoEnterprise::Jpi::V1::MarketplaceController, type: :controller do
    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env['HTTP_ACCEPT'] = 'application/json' }
    before { Rails.cache.clear }

    DEPENDENCIES = [:app_shared_entities, :'app_shared_entities.shared_entity']
    PRODUCT_DEPENDENCIES = [:'values.field', :assets, :categories, :product_pricings, :product_contracts]

    let!(:app) { build(:app) }
    let!(:product) { build(:product) }
    let(:tenant) { build(:tenant, updated_at: 2.days.ago) }

    def markdown(text)
      return text unless text.present?
      HtmlProcessor.new(text, format: :markdown).html.html_safe
    end

    def partial_hash_for_app(app)
      {
        'id' => app.id,
        'nid' => app.nid,
        'name' => app.name,
        'stack' => app.stack,
        'logo' => app.logo.to_s,
        'key_benefits' => app.key_benefits,
        'categories' => ["CRM"],
        'tags' => ['Foo', 'Bar'],
        'is_responsive' => false && app.responsive?,
        'is_star_ready' => false && app.star_ready?,
        'is_connec_ready' => false && app.connec_ready?,
        'is_coming_soon' => app.coming_soon?,
        'single_billing' => app.single_billing?,
        'tiny_description' => app.tiny_description,
        'description' => markdown(app.sanitized_description),
        'known_limitations' => markdown(app.known_limitations),
        'getting_started' => markdown(app.getting_started),
        'testimonials' => app.testimonials,
        'pictures' => app.pictures,
        'pricing_plans' => app.pricing_plans,
        'rank' => app.rank,
        'support_url' => app.support_url,
        'key_workflows' => app.key_workflows,
        'key_features' => app.key_features,
        'sso_enabled' => app.sso_enabled,
        'multi_instantiable' => app.multi_instantiable,
        'subcategories' => app.subcategories,
        'average_rating' => app.average_rating,
        'add_on' => app.add_on?,
        'running_instances_count' => app.running_instances_count,
        'pricing_text' => app.pricing_text,
        'free_trial_duration' => app.free_trial_duration,
        'free_trial_unit' => app.free_trial_unit
      }
    end

    def partial_hash_for_product(product)
      {
        "id" => product.id,
        "nid" => product.nid,
        "name" => product.name,
        "active" => product.active,
        "product_type" => product.product_type,
        "logo" => product.logo,
        "external_id" => product.external_id,
        "externally_provisioned" => product.externally_provisioned,
        "free_trial_enabled" => product.free_trial_enabled,
        "free_trial_duration" => product.free_trial_duration,
        "free_trial_unit" => product.free_trial_unit,
        "local" => product.local,
        "single_billing_enabled" => product.single_billing_enabled,
        "billed_locally" => product.billed_locally,
        "values_attributes" => product.values,
        "assets_attributes" => product.assets
      }
    end

    def hash_for_app(app)
      {
        'app' => partial_hash_for_app(app)
      }
    end

    def index_hash(apps, products)
      hash = {}
      hash['categories'] = App.categories(apps)
      hash['categories'].delete('Most Popular')

      hash['apps'] = apps.map {|a| partial_hash_for_app(a)}
      hash['products'] = products.map {|p| partial_hash_for_product(p)}

      hash
    end

    describe 'GET #index' do
      subject { get :index }

      before do
        stub_api_v2(:get, '/tenant', tenant)
        stub_api_v2(:get, '/apps', [app], DEPENDENCIES, { filter: { active: true }, sort: 'name' })
        stub_api_v2(:get, '/apps', [app], [], { fields: { apps: 'updated_at' }, page: { number: 1, size: 1 }, sort: '-updated_at' })
        stub_api_v2(:get, '/products', [product], PRODUCT_DEPENDENCIES, { filter: { active: true }, sort: 'name' } )
        stub_api_v2(:get, '/products', [product], [], { fields: { products: 'updated_at' }, page: { number: 1, size: 1 }, sort: '-updated_at' })
      end

      it { is_expected.to be_success }

      it 'returns the right response' do
        subject
        expect(JSON.parse(response.body)).to eq(JSON.parse(index_hash([app], [product]).to_json))
      end

      context 'with multiple apps' do
        let(:app1) { build(:app, name: 'A App', rank: 5) }
        let(:app2) { build(:app, name: 'C App', rank: 0) }
        let(:app3) { build(:app, name: 'B App', rank: 5) }

        before do
          # Return app sorted alphabetically (order: name)
          stub_api_v2(:get, '/apps', [app1, app3, app2], DEPENDENCIES, { filter: { active: true }, sort: 'name' })
          stub_api_v2(:get, '/products', [], PRODUCT_DEPENDENCIES, { filter: { active: true }} )
          stub_api_v2(:get, '/apps', [app], [], { fields: { apps: 'updated_at' }, page: { number: 1, size: 1 }, sort: '-updated_at' })
        end

        # Order by rank then name
        it 'returns the apps in the correct order' do
          subject
          expect(assigns(:apps).map(&:id)).to eq([app2.id, app1.id, app3.id])
        end
      end

      context 'when multiples apps and a nil rank' do
        let(:app1) { build(:app, rank: 5) }
        let(:app2) { build(:app, rank: 0) }
        let(:app3) { build(:app, rank: nil) }
        let(:product1) { build(:product) }

        before do
          stub_api_v2(:get, '/apps', [app1, app3, app2], DEPENDENCIES, { filter: { active: true }, sort: 'name' })
          stub_api_v2(:get, '/apps', [app1], [],
                      {
                        fields: { apps: 'updated_at' },
                        page: { number: 1, size: 1 },
                        sort: '-updated_at'
                      })
          stub_api_v2(:get, '/products', [product1], PRODUCT_DEPENDENCIES, { filter: { active: true }} )
          stub_api_v2(:get, '/products', [product1], [],
                      {
                        fields: { products: 'updated_at' },
                        page: { number: 1, size: 1 },
                        sort: '-updated_at'
                      })
        end

        it 'returns the apps in the correct order' do
          subject
          expect(assigns(:apps).map(&:id)).to eq([app2.id, app1.id, app3.id])
        end
      end

      context 'with organization_id' do
        subject { get :index, organization_id: organization.id }
        let!(:organization) { build(:organization) }
        let!(:user) { build(:user) }
        let!(:current_user_stub) { stub_user(user) }

        before { sign_in user }
        before { stub_api_v2(:get, "/organizations", [organization], [], { fields: { organizations: 'id' }, filter: { id: organization.id, 'users.id' => user.id }, page: { number: 1, size: 1 } }) }
        before { stub_api_v2(:get, '/apps', [app], DEPENDENCIES, { _metadata: { organization_id: organization.id }, filter: { active: true }, sort: 'name' }) }
        before { stub_api_v2(:get, '/products', [product], PRODUCT_DEPENDENCIES, { _metadata: { organization_id: organization.id }, filter: { active: true }, sort: 'name' }) }
        before do
          stub_api_v2(:get, '/apps', [app], [],
                      {
                        _metadata: { organization_id: organization.id },
                        fields: { apps: 'updated_at' },
                        page: { number: 1, size: 1 },
                        sort: '-updated_at'
                      }
          )
          stub_api_v2(:get, '/products', [product], [],
                      {
                        _metadata: { organization_id: organization.id },
                        fields: { products: 'updated_at' },
                        page: { number: 1, size: 1 },
                        sort: '-updated_at'
                      }
          )
        end

        it { is_expected.to be_success }
      end

      describe 'caching' do
        context 'on the first request' do
          it { is_expected.to have_http_status(:ok) }
          it 'sets the correct cache headers' do
            subject
            header = response.headers['Last-Modified']
            expect(header).to be_present
            # Parse and serialise to get correct format and avoid ms difference
            expect(Time.rfc822(header).in_time_zone.to_s).to eq(app.updated_at.to_s)
          end
        end
        context 'on a subsequent request' do
          before do
            request.env['HTTP_IF_MODIFIED_SINCE'] = last_modified.rfc2822
          end
          context 'if it is not stale' do
            # Can't be based on the previous request due to parsing and rounding issues with ms
            let(:last_modified) { app.updated_at + 10.minutes }
            it { is_expected.to have_http_status(:not_modified) }
          end
          context 'if it is stale' do
            let(:last_modified) { app.updated_at - 10.minutes }
            it { is_expected.to have_http_status(:ok) }
          end
        end
      end

      context 'without apps' do
        before do
          stub_api_v2(:get, '/apps', [], [],
                      {
                        fields: { apps: 'updated_at' },
                        page: { number: 1, size: 1 },
                        sort: '-updated_at'
                      }
          )
          stub_api_v2(:get, '/products', [], [],
                      {
                        fields: { apps: 'updated_at' },
                        page: { number: 1, size: 1 },
                        sort: '-updated_at'
                      }
          )
        end

        it { is_expected.to have_http_status(:ok) }

        context 'on the first request' do
          it { is_expected.to have_http_status(:ok) }
          it 'sets the correct cache headers' do
            subject
            header = response.headers['Last-Modified']
            expect(header).to be_present
            # Parse and serialise to get correct format and avoid ms difference
            expect(Time.rfc822(header).in_time_zone.to_s).to eq(tenant.updated_at.to_s)
          end
        end
        context 'on a subsequent request' do
          before do
            request.env['HTTP_IF_MODIFIED_SINCE'] = last_modified.rfc2822
          end
          context 'if it is not stale' do
            # Can't be based on the previous request due to parsing and rounding issues with ms
            let(:last_modified) { tenant.updated_at + 10.minutes }
            it { is_expected.to have_http_status(:not_modified) }
          end
          context 'if it is stale' do
            let(:last_modified) { tenant.updated_at - 10.minutes }
            it { is_expected.to have_http_status(:ok) }
          end
        end
      end
    end

    describe 'GET #show' do
      before do
        stub_api_v2(:get, "/apps/#{app.id}", app)
        stub_api_v2(:get, "/products/#{product.id}", product)

      end
      subject { get :show, id: app.id }

      it { is_expected.to be_success }
      it 'returns the right response' do
        subject
        expect(JSON.parse(response.body)).to eq(JSON.parse(hash_for_app(app).to_json))
      end
    end
  end
end
