module MnoEnterprise
  class Jpi::V2::ProductInstancesController < Jpi::V2::ApiController
    def provision
      Rails.logger.debug ({body: request.raw_post}.merge(authentication_hash).to_yaml)
      resp = MnoHubClient.post(endpoint+"/provision", {body: request.raw_post}.merge(authentication_hash))
      render_results(resp)
    end
  end
end
