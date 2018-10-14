module MnoEnterprise::Concerns::Controllers::Webhook::EventsController
  extend ActiveSupport::Concern

  #==================================================================
  # Included methods
  #==================================================================
  # 'included do' causes the included code to be evaluated in the
  # context where it is included rather than being executed in the module's context
  included do
    skip_before_action :verify_authenticity_token
  end
  

  #==================================================================
  # Instance methods
  #==================================================================
  # POST /mnoe/webhook/events
  def create
    Rails.logger.debug("Received event #{params[:event]}")
    head :ok
  end
end
