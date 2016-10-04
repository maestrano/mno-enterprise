module MnoEnterprise
  # To perform event logging asynchronously
  class EventLoggerJob < ActiveJob::Base
    queue_as :default

    def perform(action, *args)
      MnoEnterprise::EventLogger.send("send_#{action}", *args)
    end
  end
end
