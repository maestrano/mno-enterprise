require 'rails_helper'

module MnoEnterprise
  describe MnoEnterprise::Jpi::V1::MarketplaceController, type: :controller do
    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env["HTTP_ACCEPT"] = 'application/json' }
    
    let(:api_app) { build(:api_app) }
    let(:app) { MnoEnterprise::App.new(api_app) }
    
    before { api_stub_for(MnoEnterprise::App, path: '/apps', response: [api_app]) }
    before { api_stub_for(MnoEnterprise::App, path: "/apps/#{api_app[:id]}", response: api_app) }
    # def create_full_featured_app
    #   app = create(:app,
    #     key_benefits: [{text: 'Super'},{text: 'Hyper'},{text: 'Good'}],
    #     description: "Some app description",
    #     testimonials: [{text:'Bla', company:'Doe Pty Ltd', author: 'John'}],
    #     logo: "https://cdn.somedomain.com/app_logo",
    #     pictures: ["https://cdn.somedomain.com/app_screenshot"]
    #   )
    #
    #   return app
    # end
  
    def partial_hash_for_app(app)
      {
        'id' => app.id,
        'name' => app.name,
        'stack' => app.stack,
        'logo' => app.logo.to_s,
        'key_benefits' => app.key_benefits,
        'categories' => ["CRM"],
        'is_responsive' => false && app.responsive?,
        'is_star_ready' => false && app.star_ready?,
        'is_connec_ready' => false && app.connec_ready?,
        'tiny_description' => app.tiny_description,
        'description' => app.description,
        'testimonials' => app.testimonials,
        'pictures' => app.pictures
      }
    end
  
    def hash_for_app(app)
      {
        'app' => partial_hash_for_app(app)
      }
    end
  
    def hash_for_apps
      hash = {}
      hash['apps'] = []
      hash['categories'] = App.categories
      hash['categories'].delete('Most Popular')
    
      App.active.each do |app|
        hash['apps'] << partial_hash_for_app(app)
      end
    
      return hash
    end
  
    describe 'GET #index' do
      #before { create_full_featured_app }
      subject { get :index }
    
      it 'is successful' do
        subject
        expect(response).to be_success
      end
    
      it 'returns the right response' do
        subject
        expect(JSON.parse(response.body)).to eq(JSON.parse(hash_for_apps.to_json))
      end
    end
  
    describe 'GET #show' do
      #let(:app) { create_full_featured_app }
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