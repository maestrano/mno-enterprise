require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::Admin::CloudAppsController, type: :controller do
    render_views
    routes { MnoEnterprise::Engine.routes }

    # Stub model calls
    let(:admin) { build(:user, :admin) }
    let(:user) { build(:user) }

    before do
      api_stub_for(get: "/users/#{admin.id}", response: from_api(admin))
      api_stub_for(put: "/users/#{admin.id}", response: from_api(admin))
      api_stub_for(get: "/users/#{user.id}", response: from_api(user))
      api_stub_for(put: "/users/#{user.id}", response: from_api(user))
    end

    context "admin user" do
      before do
        sign_in admin
      end

      describe "#index" do
        subject { get :index }
        
        it 'returns the cloud aplications' do
          
        end
      end

      describe "#regenerate_api_key" do
        subject { put :regenerate_api_key }
        
        it 'regenerates the API key' do
          
        end
      end

      describe "#refresh_metadata" do
        subject { put :refresh_metadata }
        
        it 'refreshes the metadata' do
          
        end
      end
    end
  end

end