module MnoEnterprise
  class AuditEvent < BaseResource
    property :created_at, type: :time
    property :updated_at, type: :time

    property :organization_id
    property :user_id

    def formatted_details
      case metadata
        when String
          metadata
        when Hash
          format_serialized_details
        else
          nil
      end
    end

    def format_serialized_details
      AUDIT_LOG_CONFIG.fetch('events', {}).fetch(key, '') % metadata.symbolize_keys
    rescue KeyError => e
      e.message
      # details.inspect
    end

  end
end

