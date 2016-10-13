require 'httparty'

module MnoEnterprise
  class AuditEventsListener
    include HTTParty
    base_uri "#{MnoEnterprise.mno_api_private_host || MnoEnterprise.mno_api_host}/api/mnoe/v1/audit_events"
    read_timeout 0.1
    basic_auth MnoEnterprise.tenant_id, MnoEnterprise.tenant_key

    def info(key, current_user_id, description, subject_type, subject_id, metadata)
      self.class.post('', body: {
        data: {
          key: key,
          user_id: current_user_id,
          description: description,
          metadata: metadata,
          subject_type: subject_type,
          subject_id: subject_id
        }})
    rescue Net::ReadTimeout
      # Meant to fail
    end

  end


end

