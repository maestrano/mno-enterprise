module MnoEnterprise
  class SystemIdentity < BaseResource
    def self.table_name
      'system_identity'
    end

    def to_audit_event
      {
        system_identity_id: id,
        system_identity_name: name
      }
    end
  end
end
