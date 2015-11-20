require 'rails_helper'

module MnoEnterprise
  describe ApplicationController, type: :controller do
    # Enable CSRF protection for this test
    before { ActionController::Base.allow_forgery_protection = true }

    # Anonymous controller
    controller do
      include MnoEnterprise::Concerns::Controllers::AngularCSRF
      protect_from_forgery with: :exception

      def index
        render text: 'Hello World'
      end
    end

    describe 'Angular CSRF' do
      it 'provides the CSRF token to Angular in a cookie' do
        get :index
        expect(response.cookies['XSRF-TOKEN']).to be_instance_of(String)
      end

      it 'accepts the CSRF token to be provide via the headers' do
        get :index
        request.headers['X-XSRF-TOKEN'] = response.cookies['XSRF-TOKEN']

        post :index
        expect(response.status).to eq(200)
      end

      it 'cleans up the cookie on InvalidAuthenticityRequest' do
        post :index
        expect(response.status).to eq(422)
        expect(response.cookies['XSRF-TOKEN']).to be_instance_of(String)
      end
    end

    # Disable CSRF protection for all other tests
    after { ActionController::Base.allow_forgery_protection = false }
  end
end
