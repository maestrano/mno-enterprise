require 'rails_helper'

module MnoEnterprise
  describe PagesController, type: :controller do
    render_views
    routes { MnoEnterprise::Engine.routes }

    # Freeze time (JWT are time dependent)
    before { Timecop.freeze }
    after { Timecop.return }

    before { stub_audit_events }

    let(:user) { build(:user) }
    let(:app_instance) { build(:app_instance) }

    before do
      stub_api_v2(:get, "/users/#{user.id}", user, %i(deletion_requests organizations orga_relations dashboards))
      stub_api_v2(:get, '/app_instances', [app_instance], [], {filter:{uid: app_instance.uid}, page:{number: 1, size: 1}})
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

    describe 'GET #terms' do
      let(:app) { build(:app) }
      before {
        stub_api_v2(:get, '/apps', [app], [], {fields: {apps: 'updated_at'}, page: {number: 1, size: 1}, sort: '-updated_at'})
        stub_api_v2(:get, '/apps', [app], [], {sort: 'name'})
      }

      subject { get :terms }
      before { subject }
      it { expect(response).to be_success }
    end

  end
end
