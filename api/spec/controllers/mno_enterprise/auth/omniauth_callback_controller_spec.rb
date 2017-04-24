require 'rails_helper'

module MnoEnterprise
  describe Auth::OmniauthCallbacksController, type: :controller do
    routes { MnoEnterprise::Engine.routes }
    supported_providers = %i(linkedin google facebook)

    describe 'provides callbacks for the providers' do
      before do
        Devise.omniauth :facebook, 'key', 'secret', secure_image_url: true
        MnoEnterprise::Auth.send(:remove_const, :OmniauthCallbacksController)
        load 'app/controllers/mno_enterprise/auth/omniauth_callbacks_controller.rb'
      end
      # No described_class as it doesn't take into account the reloading above
      let(:controller) { MnoEnterprise::Auth::OmniauthCallbacksController.new }

      it { expect(controller).to respond_to(:intuit) }
      it { expect(controller).to respond_to(:facebook) }
    end
  end
end
