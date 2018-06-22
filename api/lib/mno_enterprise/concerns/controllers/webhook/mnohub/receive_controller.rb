module MnoEnterprise::Concerns::Controllers::Webhook::Mnohub::ReceiveController
  extend ActiveSupport::Concern
  #==================================================================
  # Instance methods
  #==================================================================
  # POST /mnoe/webhook/mnohub/receive
  def create
    MnoEnterprise::SystemEventsProcessorJob.perform_later
  end
end
