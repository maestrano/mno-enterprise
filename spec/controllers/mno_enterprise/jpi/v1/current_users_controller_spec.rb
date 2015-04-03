require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::CurrentUsersController, type: :controller do
    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env["HTTP_ACCEPT"] = 'application/json' }
    
    def json_for(res)
      json_hash_for(res).to_json
    end
    
    def json_hash_for(res)
      { 'current_user' => hash_for(res) }
    end
    
    def hash_for(res)
      hash = {
        'id' => res.id,
        'name' => res.name,
        'surname' => res.surname,
        'email' => res.email,
        'logged_in' => !!res.id,
        'created_at' => res.created_at ? res.created_at.iso8601 : nil,
        'company' => res.company,
        'phone' => res.phone,
        'phone_country_code' => res.phone_country_code,
        'country_code' => res.geo_country_code || 'US'
      }
      
      if res.id
        hash['organizations'] = (res.organizations || []).map do |o|
          {
            'id' => o.id,
            'name' => o.name,
            'current_user_role' => o.role
          }
        end
        
        if res.deletion_request.present?
          hash['deletion_request'] = {
            'id' => res.deletion_request.id,
            'token' => res.deletion_request.token
          }
        end
      end
      
      hash
    end
    
    # Stub user retrieval
    let!(:user) { build(:user, :with_deletion_request, :with_organizations) }
    before { api_stub_for(MnoEnterprise::User, method: :get, path: "/users/#{user.id}", response: from_api(user)) }
    
    
    describe "GET #show" do
      subject { get :show }
      
      describe 'guest' do
        it 'is successful' do
          subject
          expect(response).to be_success
        end
        
        it 'returns the right response' do
          subject
          expect(response.body).to eq(json_for(MnoEnterprise::User.new))
        end
      end
      
      describe 'logged in' do
        before { sign_in user }
        
        it 'is successful' do
          subject
          expect(response).to be_success
        end
    
        it 'returns the right response' do
          subject
          expect(response.body).to eq(json_for(user))
        end
      end
    end
    
    describe 'PUT #update' do
      let(:attrs) { { name: user.name + 'aaa' } }
      before { api_stub_for(MnoEnterprise::User, method: :put, path: "/users/#{user.id}", response: ->{ user.assign_attributes(attrs); from_api(user) }) }
      subject { put :update, user: attrs }
      
      describe 'guest' do
        before { subject }
        it { expect(response).to_not be_success }
      end
      
      describe 'logged in' do
        before { sign_in user }
        before { subject }
        it { expect(user.name).to eq(attrs[:name])}
      end
    end

  end
end