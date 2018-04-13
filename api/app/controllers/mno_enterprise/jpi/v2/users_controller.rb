module MnoEnterprise
  class Jpi::V2::UsersController < Jpi::V2::ApiController
    def update_password
      resp = MnoHubClient.patch(File.join(endpoint, params.require(:id), 'update_password'), {body: request.raw_post}.merge(authentication_hash))
      render_results(resp)
    end
  end
end
