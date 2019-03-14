module MnoEnterprise
  class Jpi::V2::UsersController < Jpi::V2::ApiController
    def show
      resp = MnoHubClient.get(File.join(endpoint, params.require(:id)), filter_params(params).merge(authentication_hash))
      render body: apply_intercom_auth(resp), content_type: 'application/vnd.api+json', status: response.code
    end

    def update_password
      resp = MnoHubClient.patch(File.join(endpoint, params.require(:id), 'update_password'), {body: request.raw_post}.merge(authentication_hash))
      render_results(resp)
    end

    private

    def apply_intercom_auth(response)
      user_hash = MnoEnterprise.intercom_enabled? && current_user.intercom_user_hash
      return response.body unless user_hash.present?

      resp_body = JSON.parse(response.body)
      resp_body['data']['attributes']['intercom_user_hash'] = user_hash
      resp_body.to_json
    end
  end
end
