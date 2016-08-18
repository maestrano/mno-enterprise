require 'rails_helper'

module MnoEnterprise
  describe PagesController, type: :controller do
    render_views
    routes { MnoEnterprise::Engine.routes }

    let(:user) { build(:user) }
    let(:app_instance) { build(:app_instance) }

    before do
      api_stub_for(get: "/users/#{user.id}", response: from_api(user))
      api_stub_for(put: "/users/#{user.id}", response: from_api(user))
      api_stub_for(get: "/app_instances", response: from_api([app_instance]))
    end

    describe 'GET #launch' do
      let(:app_instance) { build(:app_instance) }
      before { sign_in user }
      subject { get :launch, id: app_instance.uid }

      it_behaves_like "a navigatable protected user action"

      it 'redirect to the mno enterprise launch page with a web token' do
        subject
        expect(response).to redirect_to(MnoEnterprise.router.launch_url(app_instance.uid, wtk: MnoEnterprise.jwt({user_id: user.uid})))
      end
    end

    describe 'GET #launch with parameters' do
      let(:app_instance) { build(:app_instance) }
      before { sign_in user }
      subject { get :launch, id: app_instance.uid, specific_parameters: 'specific_parameters_value' }

      it_behaves_like "a navigatable protected user action"

      it 'redirects to the mno enterprise launch page with a web token and extra params' do
        subject
        expect(response).to redirect_to(MnoEnterprise.router.launch_url(app_instance.uid, wtk: MnoEnterprise.jwt({user_id: user.uid}), specific_parameters: 'specific_parameters_value'))
      end
    end

    describe 'GET #app_access_unauthorized' do
      subject { get :app_access_unauthorized }
      before { subject }
      it { expect(response).to be_success }
    end

    describe 'GET #billing_details_required' do
      subject { get :billing_details_required }
      before { subject }
      it { expect(response).to be_success }
    end

    describe 'GET #app_logout' do
      subject { get :app_logout }
      before { subject }
      it { expect(response).to be_success }
    end

  end
end
