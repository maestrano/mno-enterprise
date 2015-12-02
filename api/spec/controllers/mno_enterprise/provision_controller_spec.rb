require 'rails_helper'

module MnoEnterprise
  describe ProvisionController, type: :controller do
    render_views
    routes { MnoEnterprise::Engine.routes }

    # Create user and organization + mutual associations
    let(:organization) { build(:organization) }
    let(:user) { build(:user, :admin) }

    let!(:ability) { stub_ability }

    before do
      api_stub_for(get: "/users/#{user.id}", response: from_api(user))
      allow(organization).to receive(:users).and_return([user])
      allow_any_instance_of(User).to receive(:organizations).and_return([organization])
    end

    describe 'GET #new' do
      let(:params_org_id) { organization.id }
      let(:params) { {apps: ['vtiger'], organization_id: params_org_id} }
      subject { get :new, params }

      describe 'guest' do
        before { subject }
        it { expect(response).to redirect_to(new_user_registration_path) }
      end

      # TODO: ability to add app instances for an organization
      describe 'signed in and missing organization with multiple organizations available' do
        let(:params_org_id) { nil }
        let(:authorized) { true }
        before do
          allow_any_instance_of(User).to receive(:organizations).and_return([organization, organization])
          sign_in user
          allow(ability).to receive(:can?).with(any_args).and_return(authorized)
          subject
        end

        it { expect(response).to render_template('mno_enterprise/provision/_select_organization') }

        describe "unauthorized" do
          let(:authorized) { false }
          it { expect(response).to redirect_to(root_path) }
        end
      end

      describe 'signed in and missing organization with one organization available' do
        let(:params_org_id) { nil }
        let(:authorized) { true }
        before do
          sign_in user
          allow(ability).to receive(:can?).with(any_args).and_return(authorized)
          subject
        end

        it { expect(response).to render_template('mno_enterprise/provision/_provision_apps') }
        describe "unauthorized" do
          let(:authorized) { false }
          it { expect(response).to redirect_to(root_path) }
        end
      end
    end

    describe 'POST #create' do
      let(:params_org_id) { organization.id }
      let(:app_instance) { build(:app_instance) }
      let(:params) { {apps: ['vtiger'], organization_id: params_org_id} }
      subject { post :create, params }
      before do
        api_stub_for(get: "/organizations/#{params_org_id}/app_instances", response: from_api([app_instance]))
        api_stub_for(post: "/organizations/#{params_org_id}/app_instances", response: from_api(app_instance))
      end

      describe 'guest' do
        before { subject }
        it { expect(response).to_not be_success }
      end

      describe 'signed in' do
        let(:authorized) { true }
        before do
          sign_in user
          allow(ability).to receive(:can?).with(any_args).and_return(authorized)
          subject
        end

        it { expect(response).to be_success }
      end
    end

  end
end
