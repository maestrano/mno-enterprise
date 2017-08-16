require 'rails_helper'

module MnoEnterprise
  RSpec.describe Identity, type: :model do
    let(:auth) { OmniAuth::AuthHash.new(provider: 'test', uid: 'usr-123') }
    let(:identity) { build(:identity, provider: auth.provider, uid: auth.uid) }

    describe '.find_for_oauth' do
      subject { described_class.find_for_oauth(auth) }

      context 'when the identity exist' do
        before do
          filter = {uid: auth.uid, provider: auth.provider}
          stub_api_v2(:get, '/identities', [identity], [], {filter: filter, page: {number: 1, size: 1}})
        end

        it 'returns the existing entity' do
          expect(subject).to eq(identity)
        end
      end

      context 'when the identity does not exist' do
        before do
          filter = {uid: auth.uid, provider: auth.provider}
          stub_api_v2(:get, '/identities', [], [], {filter: filter, page: {number: 1, size: 1}})
          stub_api_v2(:post, '/identities', identity)
        end

        # find or create
        it 'creates the identity and returns it' do
          expect(subject).to eq(identity)
          assert_requested_api_v2(:post, '/identities')
        end
      end
    end
  end
end
