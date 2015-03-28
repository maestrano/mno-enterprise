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
        'created_at' => res.created_at,
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
    let(:user) { build(:user, :with_deletion_request, :with_organizations) }
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
        before { puts user.inspect; puts from_api(user) }
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
      
      
      # context "when user is logged in" do
      #   subject! do
      #     user = create(:user,free_trial_end_at: Time.now + 1.month)
      #     sign_in user
      #     user
      #   end
      #
      #   it "should be successful" do
      #     get :show
      #     response.should be_success
      #   end
      #
      #   it "should assign the current user as @current_user" do
      #     get :show
      #     assigns(:user).should == subject
      #   end
      #
      #   describe "@deletion_request" do
      #     it "contains the last active deletion request" do
      #       deletion_request = create(:deletion_request, deletable:subject)
      #       get :show
      #       expect(assigns(:deletion_request)).to eq(deletion_request)
      #     end
      #
      #     it "does not contain unactive deletion request" do
      #       # Create unactive deletion request
      #       create(:deletion_request, deletable:subject,created_at: Time.now - 1.year)
      #       get :show
      #       expect(assigns(:deletion_request)).to eq(nil)
      #     end
      #   end
      #
      #   describe "@organizations" do
      #     it "calls accessible_by on Organization" do
      #       Organization.should_receive(:accessible_by).twice.and_call_original
      #       get :show
      #     end
      #   end
      # end
      #
      # context "when user is not logged in" do
      #   it "set the new user under free trial" do
      #     get :show
      #     assigns(:user).under_free_trial?.should be_true
      #   end
      #
      #   it "assigns a new user" do
      #     get :show
      #     assigns(:user).should_not be_persisted
      #   end
      # end
    end

  end
end