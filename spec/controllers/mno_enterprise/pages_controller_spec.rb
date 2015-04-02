require 'rails_helper'

module MnoEnterprise
  describe PagesController, type: :controller do
    render_views
    routes { MnoEnterprise::Engine.routes }
  
    let(:user) { build(:user) }
    before { api_stub_for(MnoEnterprise::User, method: :get, path: "/users/#{user.id}", response: from_api(user)) }
    before { api_stub_for(MnoEnterprise::User, method: :put, path: "/users/#{user.id}", response: from_api(user)) }
  
    describe "GET #myspace" do
      before { sign_in user }
      subject { get :myspace }
      
      it_behaves_like "a navigatable protected user action"
      
      it "assigns the right meta information" do
        get :myspace
        meta = {}
        meta[:title] = "Dashboard"
        meta[:description] = "Dashboard"
        assigns(:meta).should == meta
      end
    end
    
    describe 'GET #launch' do
      let(:app_instance) { build(:app_instance) }
      before { sign_in user }
      subject { get :launch, id: app_instance.uid }
      
      it_behaves_like "a navigatable protected user action"
      
      it { subject; expect(response).to redirect_to(MnoEnterprise.router.launch_url(app_instance.uid)) }
    end
  end
end