require 'httparty'

module MnoEnterprise
  # EventLogger to log various action performed by the end users (eg: sign in, add an app, ...)
  # The EventLogger will enqueue notifications and dispatch them to the various listeners.
  # The listeners can then process these event in any way they see fit (Audit Log, Analytics, ...)
  class EventLogger
    @@listeners = [AuditEventsListener.new]
    @@listeners << IntercomEventsListener.new if MnoEnterprise.intercom_enabled?

    # Enqueue a logging job to be performed later
    #
    # @param [String] key unique key identifying the event type
    # @param [Integer] current_user_id user_id of the user triggering the event
    # @param [String] description humanised description
    # @param [Object] metadata
    # @param [Object] object
    def self.info(key, current_user_id, description, object, metadata = {})
      formatted_metadata = format_metadata(metadata, object)
      subject_type = object.class.name
      subject_id = object.id
      # TODO: improve
      # Bypass Job queuing in specs or we'd have to stub lots of Her call for the deserialization
      p Rails.env.test?
      if Rails.env.test?
        self.send_info(key, current_user_id, description, subject_type, subject_id, formatted_metadata)
      else
        MnoEnterprise::EventLoggerJob.perform_later('info', key, current_user_id, description, subject_type, subject_id, formatted_metadata)
      end
    rescue ActiveJob::SerializationError
      Rails.logger.warn "[MnoEnterprise::EventLogger] Serialization error, skipping #{key} event"
    end

    # Send the event to the listeners
    # @see .info for the params description
    def self.send_info(key, current_user_id, description, subject_type, subject_id, metadata)
      @@listeners.each do |listener|
        listener.info(key, current_user_id, description, subject_type, subject_id, metadata)
      end
    end

    # Get the metadata from the object if not provided
    def self.format_metadata(metadata, object)
      if metadata.blank? && object.respond_to?(:to_audit_event)
        object.to_audit_event
      else
        metadata
      end
    end
  end
end
