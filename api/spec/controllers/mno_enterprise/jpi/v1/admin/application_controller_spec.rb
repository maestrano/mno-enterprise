require 'rails_helper'

module MnoEnterprise
  describe ApplicationController, type: :controller do
    include ActiveSupport::Testing::TimeHelpers

    #===============================================
    # Assignments
    #===============================================
    # Stub user and user call
    let(:user) { build(:user, :admin, :with_organizations) }
    before do
      api_stub_for(get: "/users", response: from_api([user]))
      api_stub_for(get: "/users/#{user.id}", response: from_api(user))
      api_stub_for(get: "/users/#{user.id}/organizations", response: from_api(user))
      api_stub_for(put: "/users/#{user.id}", response: from_api(user))
      sign_in user
    end

    describe '#record_user_activity' do

      it 'returns the time of the last action from the user' do
        expect(subject.send(:record_user_activity)).to eq(user)
      end
    end
  end
end
