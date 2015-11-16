require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::Admin::UsersController, type: :controller do
    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env["HTTP_ACCEPT"] = 'application/json' }
    before { ActiveSupport::JSON::Encoding.time_precision = 0 }

    def partial_hash_for_user(user)
      ret = {
          'id' => user.id,
          'uid' => user.uid,
          'email' => user.email,
          'phone' => user.phone,
          'name' => user.name,
          'surname' => user.surname,
          'admin_role' => user.admin_role,
          'created_at' => user.created_at,
          'last_sign_in_at' => user.last_sign_in_at,
          'confirmed_at' => user.confirmed_at
      }
      return ret
    end

    def hash_for_users(users)
      {
          'users' => users.map { |o| partial_hash_for_user(o) }
      }
    end

    def hash_for_user(user)
      hash = {
          'user' => partial_hash_for_user(user)
      }

      return hash
    end

    #===============================================
    # Assignments
    #===============================================
    # Stub controller ability
    # let!(:ability) { stub_ability }
    # before { allow(ability).to receive(:can?).with(any_args).and_return(true) }

    # Stub user and user call
    let(:user) { build(:user, :admin) }
    before do
      api_stub_for(get: "/users", response: from_api([user]))
      api_stub_for(get: "/users/#{user.id}", response: from_api(user))
      sign_in user
    end

    #==========================
    # =====================
    # Specs
    #===============================================
    describe '#index' do
      subject { get :index }

      context 'success' do
        before { subject }

        it 'returns a list of users' do
          expect(response).to be_success
          expect(JSON.parse(response.body)).to eq(JSON.parse(hash_for_users([user]).to_json))
        end
      end
    end

    describe 'GET #show' do
      subject { get :show, id: user.id }

      context 'success' do
        before { subject }

        it 'returns a complete description of the user' do
          expect(response).to be_success
          expect(JSON.parse(response.body)).to eq(JSON.parse(hash_for_user(user).to_json))
        end
      end
    end
  end
end