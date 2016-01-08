require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::Admin::UsersController, type: :controller do
    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env["HTTP_ACCEPT"] = 'application/json' }

    def partial_hash_for_organization(user)
      user.organizations.map do |org|
        {
            'id' => org.id,
            'uid' => org.uid,
            'name' => org.name,
            'created_at' => org.created_at
        }
      end
    end

    def partial_hash_for_user(user)
      {
          'id' => user.id,
          'uid' => user.uid,
          'email' => user.email,
          'phone' => user.phone,
          'name' => user.name,
          'surname' => user.surname,
          'admin_role' => user.admin_role,
          'created_at' => user.created_at,
          'last_sign_in_at' => user.last_sign_in_at,
          'confirmed_at' => user.confirmed_at,
          'organizations' => partial_hash_for_organization(user)
      }
    end

    def partial_hash_for_users(user)
      {
          'id' => user.id,
          'uid' => user.uid,
          'email' => user.email,
          'name' => user.name,
          'surname' => user.surname,
          'admin_role' => user.admin_role,
          'created_at' => user.created_at
      }
    end

    def hash_for_users(users)
      {
          'users' => users.map { |o| partial_hash_for_users(o) },
          'metadata' => {'pagination' => {'count' => users.count}}
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
    # Stub user and user call
    let(:user) { build(:user, :admin, :with_organizations) }
    before do
      api_stub_for(get: "/users", response: from_api([user]))
      api_stub_for(get: "/users/#{user.id}", response: from_api(user))
      api_stub_for(put: "/users/#{user.id}", response: from_api(user))
      api_stub_for(get: "/users/#{user.id}/organizations", response: from_api(user))
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

    describe 'PUT #update' do
      subject { put :update, id: user.id, user: {admin_role: 'staff'} }

      before do
        api_stub_for(put: "/users/#{user.id}", response: ->{ user.admin_role = 'staff'; from_api(user) })
        subject
      end

      it { expect(response).to be_success }

      # Test that the user is updated by testing the api endpoint was called
      it { expect(user.admin_role).to eq('staff') }
    end

    describe 'DELETE #destroy' do
      let(:user_to_delete) { build(:user) }
      subject { delete :destroy, id: user_to_delete.id }

      before do
        api_stub_for(get: "/users/#{user_to_delete.id}", respond_with: user_to_delete)
        api_stub_for(delete: "/users/#{user_to_delete.id}", response: ->{ user_to_delete.name = 'deleted'; from_api(user_to_delete) })
        subject
      end

      it { expect(response).to be_success }

      # Test that the user is deleted by testing the api endpoint was called
      it { expect(user_to_delete.name).to eq('deleted') }

    end
  end
end
