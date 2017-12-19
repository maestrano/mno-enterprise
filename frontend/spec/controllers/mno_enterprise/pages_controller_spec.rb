require 'rails_helper'

module MnoEnterprise
  describe PagesController, type: :controller do
    render_views
    routes { MnoEnterprise::Engine.routes }

    describe 'GET #error' do
      subject { get :error, error_code: error_code }

      context '503 error' do
        let(:error_code) { 503 }
        it { is_expected.to have_http_status(:service_unavailable) }
        it { expect(subject.body).to match /Looks like we're having some server issues./ }
      end

      context '429 error' do
        let(:error_code) { 429 }
        it { is_expected.to have_http_status(:too_many_requests) }
        it { expect(subject.body).to match /Too many requests./ }
      end
    end
  end
end
