require 'rails_helper'

module MnoEnterprise
  describe MnoEnterprise::Jpi::V1::MarketplaceController, type: :controller do
    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env["HTTP_ACCEPT"] = 'application/json' }

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
        'testimonials' => app.testimonials,
        'pictures' => app.pictures,
        'pricing_plans' => app.pricing_plans,
        'rank' => app.rank
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

      context 'when marketplace_listing is set' do
        before do
          MnoEnterprise.marketplace_listing = [app.nid]
          api_stub_for(
            get: '/apps',
            params: { filter: { 'nid.in' => MnoEnterprise.marketplace_listing } },
            response: from_api([app])
          )
        end

        it 'is successful' do
          subject
          expect(response).to be_success
        end

        it 'returns the right response' do
          subject
          expect(JSON.parse(response.body)).to eq(JSON.parse(hash_for_apps([app]).to_json))
        end
      end

      context 'when marketplace_listing is not set' do
        before do
          MnoEnterprise.marketplace_listing = nil
          api_stub_for(get: '/apps', response: from_api([app]))
        end

        it 'is successful' do
          subject
          expect(response).to be_success
        end

        it 'returns the right response' do
          subject
          expect(JSON.parse(response.body)).to eq(JSON.parse(hash_for_apps([app]).to_json))
        end
      end
    end

    describe 'GET #show' do
      before { api_stub_for(get: "/apps/#{app.id}", response: from_api(app)) }
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
     
    describe 'GET #index' do
      subject { get :index }

      context 'when multiples apps' do 
        let(:app1) { build(:app, rank: 5 ) }
        let(:app2) { build(:app, rank: 0 ) }

        before do  
          MnoEnterprise.marketplace_listing = nil
          api_stub_for(get: '/apps', response: from_api([app1,app2]))
        end

        it 'is successful' do
          subject
          expect(response).to be_success
        end

        it 'returns the right response' do
          subject
          expect(JSON.parse(response.body)).to eq(JSON.parse(hash_for_apps([app2, app1]).to_json))
        end 
      end
      
      context 'when multiples apps and attributes nil' do 
        let(:app1) { build(:app, rank: 5 ) }
        let(:app2) { build(:app, rank: 0 ) }
        let(:app3) { build(:app, rank: nil ) }

        before do  
          MnoEnterprise.marketplace_listing = nil
          api_stub_for(get: '/apps', response: from_api([app1,app3,app2]))
        end

        it 'returns the right response' do
          subject
          expect(JSON.parse(response.body)).to eq(JSON.parse(hash_for_apps([app2, app1, app3]).to_json))
        end   
      end
    end
  end
end
