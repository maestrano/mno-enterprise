require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::CurrentUsersController, type: :controller do
    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env["HTTP_ACCEPT"] = 'application/json' }

    include MnoEnterprise::ApplicationHelper # For #avatar_url

    # Times need to be frozen to deal with deletion requests
    before do
      Timecop.freeze(Time.local(1985, 9, 17))
    end

    after do
      Timecop.return
    end

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
        'api_secret' => res.api_secret,
        'api_key' => res.api_key,
        'phone_country_code' => res.phone_country_code,
        'country_code' => res.geo_country_code || 'US',
        'website' => res.website,
        'sso_session' => res.sso_session,
        'admin_role' => res.admin_role,
        'avatar_url' => avatar_url(res),
        'settings' => res.settings,
        'sub_tenant_id' => res.sub_tenant&.id,
        'user_hash' => res.intercom_user_hash
      }

      if res.id
        hash['admin_role'] = res.admin_role
        hash['organizations'] = (res.organizations || []).map do |o|
          {
            'id' => o.id,
            'uid' => o.uid,
            'name' => o.name,
            'currency' => 'AUD',
            'current_user_role' => res.role(o),
            'has_myob_essentials_only' => o.has_myob_essentials_only,
            'financial_year_end_month' => o.financial_year_end_month
          }
        end

        if res.current_deletion_request.present?
          hash['deletion_request'] = {
            'id' => res.deletion_request.id,
            'token' => res.deletion_request.token
          }
        end

        hash['kpi_enabled'] = !!res.kpi_enabled
      end
      hash
    end

    before { stub_audit_events }

    shared_examples 'a user management action' do
      context 'when Organization management is disabled' do
        before { Settings.merge!(dashboard: { user_management: { enabled: false } }) }
        before { sign_in user }
        after { Settings.reload! }

        it { is_expected.to have_http_status(:forbidden) }
      end
    end

    # Stub user retrieval
    let(:organization) { build(:organization) }
    let!(:user) { build(:user, :kpi_enabled, organizations: [organization], orga_relations: [orga_relation]) }

    let!(:orga_relation) { build(:orga_relation, organization: organization) }

    let!(:current_user_stub) { stub_user(user) }

    before do
      stub_orga_relation(user, organization, orga_relation)
      stub_deletion_requests(user, [])
    end

    describe 'GET #show' do
      subject { get :show }

      before do
        stub_user(user, MnoEnterprise::Concerns::Controllers::Jpi::V1::CurrentUsersController::INCLUDED_DEPENDENCIES)
      end

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
          expect(JSON.parse(response.body)).to eq(json_hash_for(user))
        end
      end
    end

    describe 'PUT #update' do
      let(:attrs) { { name: user.name + 'aaa' } }

      before {
        updated_user = build(:user, id: user.id)
        updated_user.attributes = attrs
        stub_api_v2(:patch, "/users/#{user.id}", updated_user)
        # user reload
        stub_user(updated_user, MnoEnterprise::Concerns::Controllers::Jpi::V1::CurrentUsersController::INCLUDED_DEPENDENCIES)
      }

      subject { put :update, user: attrs }

      it_behaves_like 'a user management action'

      describe 'guest' do
        before { subject }
        it { expect(response).to_not be_success }
      end

      describe 'logged in' do
        before { sign_in user }
        before { subject }
        it { expect(assigns(:user).name).to eq(attrs[:name]) }
      end
    end

    describe 'PUT #register_developer' do
      subject { put :register_developer }
      before do
        sign_in user
        stub_api_v2(:patch, "/users/#{user.id}/create_api_credentials", user)
        #user reload
        stub_user(user, MnoEnterprise::Concerns::Controllers::Jpi::V1::CurrentUsersController::INCLUDED_DEPENDENCIES)
        subject
      end
      describe 'logged in' do
        it { expect(response).to be_success }
      end
    end

    describe 'PUT #update_password' do
      subject { put :update_password, user: attrs }

      let(:attrs) { { current_password: 'password', password: 'blablabla', password_confirmation: 'blablabla' } }
      let!(:update_password_stub) { stub_api_v2(:patch, "/users/#{user.id}/update_password", user) }
      #user reload
      before { stub_user(user, MnoEnterprise::Concerns::Controllers::Jpi::V1::CurrentUsersController::INCLUDED_DEPENDENCIES) }

      it_behaves_like 'a user management action'

      describe 'guest' do
        before { subject }
        it { expect(response).to_not be_success }
      end

      describe 'logged in' do
        before { sign_in user }
        before { subject }
        it { expect(response).to be_success }
        it { expect(update_password_stub).to have_been_requested }
        it { expect(controller.current_user.id).to eq(user.id) } # check user is re-signed in
      end
    end
  end
end
