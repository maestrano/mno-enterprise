module MnoEnterprise
  # TODO: Verify headers (content_type & accept)
  # TODO: respond_to?
  class Jpi::V2::ApiController < ApplicationController
    # TODO: Enable xsrf
    skip_before_filter :verify_authenticity_token


    def index
      resp = mnohub_client.get(endpoint, params)
      render_results(resp)
    end

    def show
      resp = mnohub_client.get(File.join(endpoint, params.require(:id)), params)
      render_results(resp)
    end

    def create
      resp = mnohub_client.post(endpoint, {body: request.raw_post})
      render_results(resp)
    end

    def update
      resp = mnohub_client.patch(File.join(endpoint, params.require(:id)), {body: request.raw_post})
      render_results(resp)
    end

    def destroy
      resp = mnohub_client.delete(File.join(endpoint, params.require(:id)))
      render_results(resp)
    end

    private

    def render_results(response)
      render body: response.body, content_type: 'application/vnd.api+json', status: response.code
    end

    def mnohub_client
      @mnohub_client ||= MnoHubClient.new
    end

    def endpoint
      @endpoint ||= self.class.name.demodulize.underscore.sub(/_controller$/, '')
    end
  end
end
