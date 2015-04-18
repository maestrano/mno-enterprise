require 'rails_helper'

module MnoEnterprise
  describe OrgInvitesController, type: :controller do
    render_views
    routes { MnoEnterprise::Engine.routes }
  
    let(:user) { build(:user) }
    #before { api_stub_for(MnoEnterprise::User, method: :get, path: "/users/#{user.id}", response: from_api(user)) }
    #before { api_stub_for(MnoEnterprise::User, method: :put, path: "/users/#{user.id}", response: from_api(user)) }
  
    describe "GET #show" do
      before { sign_in user }
      subject { get :show }
      
      # it_behaves_like "a navigatable protected user action"
      #
      # it "assigns the right meta information" do
      #   get :myspace
      #   meta = {}
      #   meta[:title] = "Dashboard"
      #   meta[:description] = "Dashboard"
      #   assigns(:meta).should == meta
      # end
    end
  
  end
  
end