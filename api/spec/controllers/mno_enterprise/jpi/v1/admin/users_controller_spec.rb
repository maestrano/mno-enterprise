require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::Admin::UsersController, type: :controller do
    include MnoEnterprise::TestingSupport::SharedExamples::JpiV1Admin
    #TODO: Fix Spec for Admin Controller
    before { skip }

    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env["HTTP_ACCEPT"] = 'application/json' }

    def partial_hash_for_organization(user)
      user.organizations.map do |org|
        {
            'id' => org.id,
            'uid' => org.uid,
            'name' => org.name,
            'created_at' => org.created_at,
            'account_frozen' => org.account_frozen
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
          'sign_in_count' => user.sign_in_count
      }
    end

    def hash_for_users(users)
      {
          'users' => users.map { |o| partial_hash_for_user(o) },
          'metadata' => {'pagination' => {'count' => users.count}}
      }
    end

    def hash_for_user(user)
      hash = {
          'user' => partial_hash_for_user(user).merge('organizations' => partial_hash_for_organization(user))
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
      api_stub_for(get: "/users/#{user.id}/organizations", response: from_api(user))
      sign_in user
    end

    #==========================
    # =====================
    # Specs
    #===============================================
    describe '#index' do
      subject { get :index }

      it_behaves_like "a jpi v1 admin action"

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

      it_behaves_like "a jpi v1 admin action"

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
      let(:current_user) { build(:user, :admin) }

      before do
        api_stub_for(get: "/users/#{current_user.id}", response: from_api(current_user))
        sign_in current_user

        user.admin_role = nil
        api_stub_for(put: "/users/#{user.id}", response: -> { user.admin_role = 'staff'; from_api(user) })
      end

      it_behaves_like "a jpi v1 admin action"

      context 'success' do
        before { subject }

        context 'when admin' do
          it { expect(response).to be_success }

          # Test that the user is updated by testing the api endpoint was called
          it { expect(user.admin_role).to eq('staff') }
        end

        context 'when staff' do
          let(:current_user) { build(:user, :staff) }

          it { expect(response).to have_http_status(:unauthorized) }

          it { expect(user.admin_role).to be_nil }
        end
      end
    end

    describe 'DELETE #destroy' do
      let(:user_to_delete) { build(:user) }
      subject { delete :destroy, id: user_to_delete.id }

      before do
        api_stub_for(get: "/users/#{user_to_delete.id}", respond_with: user_to_delete)
        api_stub_for(delete: "/users/#{user_to_delete.id}", response: ->{ user_to_delete.name = 'deleted'; from_api(user_to_delete) })
      end

      it_behaves_like "a jpi v1 admin action"

      context 'success' do
        before { subject }

        # Test that the user is deleted by testing the api endpoint was called
        it { expect(user_to_delete.name).to eq('deleted') }
      end
    end

    describe 'POST #signup_email' do
      let(:email) { 'test@test.com' }
      subject { post :signup_email, user: {email: email}}

      it_behaves_like "a jpi v1 admin action"

      it 'sends the signup instructions' do
        message_delivery = instance_double(ActionMailer::MessageDelivery)
        expect(SystemNotificationMailer).to receive(:registration_instructions).with(email) { message_delivery }
        expect(message_delivery).to receive(:deliver_later).with(no_args)
        subject
      end
    end
  end
end
