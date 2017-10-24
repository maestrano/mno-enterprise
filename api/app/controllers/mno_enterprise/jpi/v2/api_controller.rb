module MnoEnterprise
  # TODO: Verify headers (content_type & accept)
  # TODO: respond_to?

  class Jpi::V2::ApiController < ApplicationController
    # TODO: Enable xsrf
    skip_before_filter :verify_authenticity_token


    def index
      resp = MnoHubClient.get(endpoint, filter_params(params).merge(authentication_hash))
      render_results(resp)
    end

    def show
      resp = MnoHubClient.get(File.join(endpoint, params.require(:id)), filter_params(params).merge(authentication_hash))
      render_results(resp)
    end

    def create
      resp = MnoHubClient.post(endpoint, {body: request.raw_post}.merge(authentication_hash))
      render_results(resp)
    end

    def update
      resp = MnoHubClient.patch(File.join(endpoint, params.require(:id)), {body: request.raw_post}.merge(authentication_hash))
      render_results(resp)
    end

    def destroy
      resp = MnoHubClient.delete(File.join(endpoint, params.require(:id)), authentication_hash)
      render_results(resp)
    end

    private

    def authentication_hash
      {basic_auth: {username: current_user.sso_session, password: ''}}
    end

    # Filter params to only forward the params we need
    def filter_params(params)
      # options[:query] = options[:query].inject({}) { |h, q| h[q[0].to_s.camelize] = q[1]; h }
      {
        query: params.permit(
          :include,
          page: [:number, :size]
        )
      }
    end

    def render_results(response)
      render body: response.body, content_type: 'application/vnd.api+json', status: response.code
    end

    def endpoint
      @endpoint ||= "/#{self.class.name.demodulize.underscore.sub(/_controller$/, '')}"
    end
  end
end
