require 'httparty'

module MnoEnterprise
  class EventLogger
    @@listeners = [AuditEventsListener.new]
    @@listeners << IntercomEventsListener.new if MnoEnterprise.intercom_enabled?

    def self.info(key, current_user_id, description, metadata, object)
      formatted_metadata = format_metadata(metadata, object)
      @@listeners.each do |listener|
        listener.info(key, current_user_id, description, formatted_metadata, object)
      end
    end

    def self.format_metadata(metadata, object)
      if metadata.blank? && object.respond_to?(:to_audit_event)
        object.to_audit_event
      else
        metadata
      end
    end
  end
end
