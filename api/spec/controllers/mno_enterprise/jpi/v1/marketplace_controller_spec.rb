require 'rails_helper'

module MnoEnterprise
  describe MnoEnterprise::Jpi::V1::MarketplaceController, type: :controller do
    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env["HTTP_ACCEPT"] = 'application/json' }

    let!(:app) { build(:app) }

    before { api_stub_for(
      get: '/apps',
      params: { filter: { 'nid.in' => MnoEnterprise.marketplace_listing } },
      response: from_api([app])
    )}
    before { api_stub_for(get: "/apps/#{app.id}", response: from_api(app)) }

    def partial_hash_for_app(app)
      {
        'id' => app.id,
        'nid' => app.nid,
        'name' => app.name,
        'stack' => app.stack,
        'logo' => app.logo.to_s,
        'key_benefits' => app.key_benefits,
        'categories' => ["CRM"],
        'is_responsive' => false && app.responsive?,
        'is_star_ready' => false && app.star_ready?,
        'is_connec_ready' => false && app.connec_ready?,
        'tiny_description' => app.tiny_description,
        'description' => app.sanitized_description,
        'testimonials' => app.testimonials,
        'pictures' => app.pictures
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

      it 'is successful' do
        subject
        expect(response).to be_success
      end

      it 'returns the right response' do
        subject
        expect(JSON.parse(response.body)).to eq(JSON.parse(hash_for_apps([app]).to_json))
      end
    end

    describe 'GET #show' do
      subject { get :show, id: app.id }

      it 'is successful' do
        subject
        expect(response).to be_success
      end

      it 'returns the right response' do
        subject
        expect(JSON.parse(response.body)).to eq(JSON.parse(hash_for_app(app).to_json))
      end
    end
  end
end
