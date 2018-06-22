module MnoEnterprise
  class SystemEventsProcessor
    
    def self.process
      MnoEnterprise::SystemEvent.fetch_all.each do |system_event|
        next if system_event.event != 'order_status_change' &&
                system_event.resource_type != "subscription_events"
        MnoEnterprise::SystemNotificationMailer.order_status_changed(system_event.id).deliver_later
      end
    end
  end
end
