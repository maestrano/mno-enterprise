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
          api_stub_for(get: "/identities", params: {filter: filter}, response: from_api([identity]))
          # We don't stub POST identities therefore testing there's no creation
        end

        it 'returns the existing entity' do
          expect(subject).to eq(identity)
        end
      end

      context 'when the identity does not exist' do
        before do
          filter = {uid: auth.uid, provider: auth.provider}
          api_stub_for(get: "/identities", params: {filter: filter}, response: from_api([]))

          # Test that it creates the entity? How can we add expect on post?
          api_stub_for(post: "/identities", response: from_api(identity))
        end

        # find or create
        it 'creates the identity and returns it' do
          expect(subject).to eq(identity)
        end
      end
    end
  end
end
