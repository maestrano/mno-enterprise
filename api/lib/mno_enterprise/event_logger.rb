require 'httparty'

module MnoEnterprise
  class EventLogger
    include HTTParty
    base_uri "#{MnoEnterprise.mno_api_private_host || MnoEnterprise.mno_api_host}/api/mnoe/v1/audit_events"
    read_timeout 0.1
    basic_auth MnoEnterprise.tenant_id, MnoEnterprise.tenant_key

    def self.info(key, current_user_id, description, metadata, object)
      post('', body: {
          data: {
              key: key,
              user_id: current_user_id,
              description: description,
              metadata: format_metadata(metadata, object),
              subject_type: object.class.name,
              subject_id: object.id
          }})
    rescue Net::ReadTimeout
      # Meant to fail
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
