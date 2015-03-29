require 'rails_helper'

module MnoEnterprise
  describe PagesController do
    render_views
    routes { MnoEnterprise::Engine.routes }
  
    let(:user) { build(:user) }
    before { api_stub_for(MnoEnterprise::User, method: :get, path: "/users/#{user.id}", response: from_api(user)) }
    before { api_stub_for(MnoEnterprise::User, method: :put, path: "/users/#{user.id}", response: from_api(user)) }
  
    describe "GET #myspace" do
      describe "guest" do
        it "redirects to the login page" do
          get :myspace
          response.should redirect_to(new_user_session_path)
        end
      end

      describe "when signed in and unconfirmed" do
        let(:user) { build(:user, :unconfirmed) }
        before { sign_in user }
        before(:each) do
          sign_in user
        end

        it "redirect to the email lounge" do
          get :myspace
          response.should redirect_to(user_confirmation_lounge_path)
        end
      end

      describe "when signed in and confirmed" do
        before { sign_in user }

        it "is successful" do
          get :myspace
          response.should be_success
        end

        it "assigns the right meta information" do
          get :myspace
          meta = {}
          meta[:title] = "Dashboard"
          meta[:description] = "Dashboard"
          assigns(:meta).should == meta
        end
      end
    end
  end
end