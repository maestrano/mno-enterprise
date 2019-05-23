require 'rails_helper'

RSpec.describe Devise::Models::SessionLimitable do
  let(:user) { build(:user, :persisted, email: 'test@maestrano.com', password: 'oldpass') }

  before do
    stub_api_v2(:get, '/users', [], [], {filter: {email: 'test@maestrano.com'}, page: {number: 1, size: 1}})
    stub_api_v2(:post, '/users', user)
  end

  describe 'change unique_session_id when user logs in again' do
  end
end
