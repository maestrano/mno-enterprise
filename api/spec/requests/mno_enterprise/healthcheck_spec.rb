require 'rails_helper'

module MnoEnterprise
  # Test the Status controller is still working when MnoHub is down
  # The behavior is tested in the ControllerSpec
  RSpec.describe "Health Check", type: :request do
    include MnoEnterprise::TestingSupport::RequestSpecHelper

    describe 'simple' do
      subject { get '/mnoe/health_check.json' }
      let(:data) { JSON.parse(response.body) }

      context 'with a signed in user' do
        include_context 'signed in user'

        context 'when MnoHub is up' do
          before { subject }

          it { expect(response).to have_http_status(:ok), response.body }
          it { expect(data['healthy']).to be true }
        end

        context 'when MnoHub is down' do
          before { clear_api_stubs }
          before { subject }

          it { expect(response).to have_http_status(:ok), response.body }
          it { expect(data['healthy']).to be true }
        end
      end
    end

    describe 'full' do
      subject { get '/mnoe/health_check/full.json' }
      let(:data) { JSON.parse(response.body) }

      context 'with a signed in user' do
        include_context 'signed in user'

        context 'when MnoHub is up' do
          before { api_stub_for(get: '/apps?limit=1&sort[]=id.asc', response: from_api([FactoryGirl.build(:app)])) }
          before { subject }

          it { expect(response).to have_http_status(:ok), response.body }
          it { expect(data['healthy']).to be true }
        end

        context 'when MnoHub is down' do
          before { clear_api_stubs }
          before { subject }

          it { expect(response).to have_http_status(:internal_server_error), response.body }
          it { expect(data['healthy']).to be false }
        end
      end
    end
  end
end
