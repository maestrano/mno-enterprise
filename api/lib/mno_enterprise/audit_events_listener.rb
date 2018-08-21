require 'httparty'

module MnoEnterprise
  class AuditEventsListener

    def info(key, current_user_id, description, subject_type, subject_id, metadata)
      data = {
        key: key,
        user_id: current_user_id,
        description: description,
        metadata: metadata,
        subject_type: subject_type,
        subject_id: subject_id
      }
      organization_id = if (subject_type == 'MnoEnterprise::Organization') then
                          subject_id
                        elsif metadata.is_a?(Hash)
                          metadata["organization_id"].presence
                        end
      data[:organization_id] = organization_id if organization_id
      MnoEnterprise::AuditEvent.create(data)
    end
  end
end
