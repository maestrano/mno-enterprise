RSpec.shared_context MnoEnterprise::Jpi::V1::Admin::BaseResourceController do
  include MnoEnterprise::TestingSupport::SharedExamples::JpiV1Admin

  render_views
  routes { MnoEnterprise::Engine.routes }
  before { request.env["HTTP_ACCEPT"] = 'application/json' }

  # user is stubbed in the controller?
  before do
    api_stub_for(get: "/users/#{user.id}", response: from_api(user))
    sign_in(user)
  end
end
