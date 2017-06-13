require 'rails_helper'

module MnoEnterprise
  describe MnoEnterprise::Jpi::V1::MarketplaceController, type: :controller do
    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env["HTTP_ACCEPT"] = 'application/json' }
    before { Rails.cache.clear }

    let!(:app) { build(:app) }

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
        'key_workflows'  => app.key_workflows,
        'key_features' => app.key_features,
        'multi_instantiable' => app.multi_instantiable,
        'subcategories' => app.subcategories,
        'average_rating' => app.average_rating,
        'add_on' => app.add_on?,
        'running_instances_count' => app.running_instances_count
      }
    end

    def hash_for_app(app)
      {
        'app' => partial_hash_for_app(app)
      }
    end

    def hash_for_apps(apps)
      hash = {}
      hash['apps'] = []
      hash['categories'] = App.categories(apps)
      hash['categories'].delete('Most Popular')

      apps.each do |app|
        hash['apps'] << partial_hash_for_app(app)
      end

      return hash
    end

    describe 'GET #index' do
      subject { get :index }

      before do
        api_stub_for(get: '/apps', response: from_api([app]))
        # TODO: Shouldn't need to stub this
        api_stub_for(get: "/apps/#{app.id}/shared_entities", response: from_api([]))
      end

      it { is_expected.to be_success }

      it 'returns the right response' do
        subject
        expect(JSON.parse(response.body)).to eq(JSON.parse(hash_for_apps([app]).to_json))
      end

      context 'with multiple apps' do
        let(:app1) { build(:app, rank: 5 ) }
        let(:app2) { build(:app, rank: 0 ) }

        before do
          api_stub_for(get: '/apps', response: from_api([app1, app2]))
          # TODO: Shouldn't need to stub this
          api_stub_for(get: "/apps/#{app1.id}/shared_entities", response: from_api([]))
          api_stub_for(get: "/apps/#{app2.id}/shared_entities", response: from_api([]))
        end

        it 'returns the apps in the correct order' do
          subject
          expect(assigns(:apps)).to eq([app2, app1])
        end
      end

      context 'when multiples apps and a nil rank' do
        let(:app1) { build(:app, rank: 5 ) }
        let(:app2) { build(:app, rank: 0 ) }
        let(:app3) { build(:app, rank: nil ) }

        before do
          api_stub_for(get: '/apps', response: from_api([app1, app3, app2]))
          # TODO: Shouldn't need to stub this
          api_stub_for(get: "/apps/#{app1.id}/shared_entities", response: from_api([]))
          api_stub_for(get: "/apps/#{app2.id}/shared_entities", response: from_api([]))
          api_stub_for(get: "/apps/#{app3.id}/shared_entities", response: from_api([]))
        end

        it 'returns the apps in the correct order' do
          subject
          expect(assigns(:apps)).to eq([app2, app1, app3])
        end
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

        context 'on a subsequent request'  do

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
    end

    describe 'GET #show' do
      before do
        api_stub_for(get: "/apps/#{app.id}", response: from_api(app))
        # TODO: Shouldn't need to stub this
        api_stub_for(get: "/apps/#{app.id}/shared_entities", response: from_api([]))
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
