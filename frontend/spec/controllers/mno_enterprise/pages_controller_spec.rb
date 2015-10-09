require 'rails_helper'

module MnoEnterprise
  describe PagesController, type: :controller do
    render_views
    routes { MnoEnterprise::Engine.routes }
  
    let(:user) { build(:user) }
    before { api_stub_for(get: "/users/#{user.id}", response: from_api(user)) }
    before { api_stub_for(put: "/users/#{user.id}", response: from_api(user)) }
  
    describe "GET #myspace" do
      before { sign_in user }
      subject { get :myspace }
      
      it_behaves_like "a navigatable protected user action"
      
      it "assigns the right meta information" do
        get :myspace
        meta = {}
        meta[:title] = "Dashboard"
        meta[:description] = "Dashboard"
        expect(assigns(:meta)).to eq(meta)
      end
    end

    # To be sure that we don't loose pages define in mnoe-api
    describe 'GET #launch' do
      let(:app_instance) { build(:app_instance) }
      before { sign_in user }
      subject { get :launch, id: app_instance.uid }

      it_behaves_like "a navigatable protected user action"

      it 'redirect to the mno enterprise launch page with a web token' do
        subject
        expect(response).to redirect_to(MnoEnterprise.router.launch_url(app_instance.uid, wtk: MnoEnterprise.jwt({user_id: user.uid })))
      end
    end
  end
end
