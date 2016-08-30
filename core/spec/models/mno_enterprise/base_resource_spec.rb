require 'rails_helper'

module MnoEnterprise
  RSpec.describe BaseResource, type: :model do
    describe 'Error Handling' do
      class Test < BaseResource; end

      context 'Connection Errors' do
        ((502..504).to_a<<407).each do |code|
          it "handles #{code} error" do
            api_stub_for(get: "/tests/1", code: code)
            expect { Test.find(1) }.to raise_error(Faraday::ConnectionFailed)
          end
        end
      end

      context 'Server Errors' do
        [401, 500].each do |code|
          it "handles #{code} error" do
            api_stub_for(get: "/tests/1", code: code)
            expect { Test.find(1) }.to raise_error(Faraday::Error::ClientError)
          end
        end
      end
    end

    describe '#cache_key' do
      context 'for existing record' do
        let(:user) { build(:user) }

        it 'uses updated_at' do
          expect(user.cache_key).to eq("mno_enterprise/users/#{user.id}-#{user.updated_at.utc.to_s(:nsec)}")
        end

        context 'when updated_at is nil' do
          before { user.updated_at = nil }
          it { expect(user.cache_key).to eq("mno_enterprise/users/#{user.id}") }
        end

        it 'uses the named timestamp' do
          expect(user.cache_key(:confirmed_at)).to eq("mno_enterprise/users/#{user.id}-#{user.confirmed_at.utc.to_s(:nsec)}")
        end
      end

      context 'for new record' do
        it { expect(User.new.cache_key).to eq('mno_enterprise/users/new') }
      end
    end
  end
end
