module MnoEnterprise
  class SystemEventsProcessorJob < ActiveJob::Base
    queue_as :default

    def perform(*args)
      MnoEnterprise::SystemEventsProcessor.process
    end
  end
end
