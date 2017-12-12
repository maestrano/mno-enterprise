require 'rails_helper'

module MnoEnterprise
  # Test the Status controller is still working when MnoHub is down
  # The behavior is tested in the ControllerSpec
  RSpec.describe "Status", type: :request do
    include MnoEnterprise::TestingSupport::RequestSpecHelper

    describe 'version' do
      subject { get '/mnoe/version' }
      let(:data) { JSON.parse(response.body) }

      context 'with a signed in user' do
        include_context 'signed in user'

        context 'when MnoHub is up' do
          before { subject }

          it { expect(response).to have_http_status(:ok) }
        end

        context 'when MnoHub is down' do
          before { clear_api_stubs }
          before { subject }

          it { expect(response).to have_http_status(:ok) }
        end
      end

      context 'without a signed in user' do
        before { subject }
        it { expect(response).to have_http_status(:ok) }
      end
    end

    describe 'ping' do
      subject { get '/mnoe/ping' }

      context 'with a signed in user' do
        include_context 'signed in user'

        context 'when MnoHub is up' do
          before { subject }

          it { expect(response).to have_http_status(:ok) }
        end

        context 'when MnoHub is down' do
          before { clear_api_stubs }
          before { subject }

          it { expect(response).to have_http_status(:ok) }
        end
      end

      context 'without a signed in user' do
        before { subject }
        it { expect(response).to have_http_status(:ok) }
      end
    end
  end
end
