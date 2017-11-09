require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::CurrentUsersController, type: :controller do
    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env["HTTP_ACCEPT"] = 'application/json' }

    include MnoEnterprise::ApplicationHelper # For #avatar_url

    def json_for(res)
      json_hash_for(res).to_json
    end

    def json_hash_for(res)
      {'current_user' => hash_for(res)}
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
          'avatar_url' => avatar_url(res)
      }

      if res.id
        hash['admin_role'] = res.admin_role
        hash['organizations'] = (res.organizations || []).map do |o|
          {
              'id' => o.id,
              'uid' => o.uid,
              'orga_relation_id' => o.orga_relation_id,
              'name' => o.name,
              'currency' => 'AUD',
              'current_user_role' => o.role,
              'has_myob_essentials_only' => o.has_myob_essentials_only?,
              'financial_year_end_month' => o.financial_year_end_month
          }
        end

        if res.deletion_request.present?
          hash['deletion_request'] = {
              'id' => res.deletion_request.id,
              'token' => res.deletion_request.token
          }
        end

        hash['kpi_enabled'] = !!res.kpi_enabled
      end

      hash
    end

    shared_examples "a user management action" do
      context 'when Organization management is disabled' do
        before { Settings.merge!(user_management: {enabled: false}) }
        before { sign_in user }
        after { Settings.reload! }

        it { is_expected.to have_http_status(:forbidden) }
      end
    end

    # Stub user retrieval
    let!(:user) { build(:user, :with_deletion_request, :with_organizations, :kpi_enabled) }
    before { api_stub_for(get: "/users/#{user.id}", response: from_api(user)) }
    before { api_stub_for(get: "/users/#{user.id}/organizations?filter%5Baccount_frozen%5D=false", response: from_api(user.organizations)) }


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
      let(:attrs) { {name: user.name + 'aaa'} }
      before { api_stub_for(put: "/users/#{user.id}", response: -> { user.assign_attributes(attrs); from_api(user) }) }

      subject { put :update, user: attrs }

      it_behaves_like 'a user management action'

      describe 'guest' do
        before { subject }
        it { expect(response).to_not be_success }
      end

      describe 'logged in' do
        before { sign_in user }
        before { subject }
        it { expect(user.name).to eq(attrs[:name]) }
      end
    end

    describe 'PUT #register_developer' do
      before { api_stub_for(put: "/users/#{user.id}", response: from_api(user)) }
      before { sign_in user }
      subject { put :register_developer}

      describe 'logged in' do
        before { subject }
        it { expect(response).to be_success }
      end
    end

    describe 'PUT #update_password' do
      let(:attrs) { {current_password: 'password', password: 'blablabla', password_confirmation: 'blablabla'} }
      before { api_stub_for(put: "/users/#{user.id}", response: from_api(user)) }

      subject { put :update_password, user: attrs }

      it_behaves_like 'a user management action'

      describe 'guest' do
        before { subject }
        it { expect(response).to_not be_success }
      end

      describe 'logged in' do
        before { sign_in user }
        before { subject }
        it { expect(response).to be_success }
        it { expect(controller.current_user).to eq(user) } # check user is re-signed in
      end
    end
  end
end
