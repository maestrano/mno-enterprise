require 'httparty'

module MnoEnterprise
  class AuditEventsListener
    include HTTParty
    base_uri "#{MnoEnterprise.mno_api_private_host || MnoEnterprise.mno_api_host}/api/mnoe/v1/audit_events"
    read_timeout 0.1
    basic_auth MnoEnterprise.tenant_id, MnoEnterprise.tenant_key

    def info(key, current_user_id, description, subject_type, subject_id, metadata)
      organization_id = if (subject_type == 'MnoEnterprise::Organization') then
                          subject_id
                        elsif metadata.is_a?(Hash)
                          metadata[:organization_id].presence
                        end
      body = {
        data: {
          key: key,
          user_id: current_user_id,
          description: description,
          metadata: metadata,
          subject_type: subject_type,
          subject_id: subject_id,
        }
      }
      body[:data][:organization_id] = organization_id if organization_id
      self.class.post('', body: body)
    rescue Net::ReadTimeout
      # Meant to fail
    end
  end
end

