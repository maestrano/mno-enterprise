module MnoEnterprise
  class EventLogger

    def self.new_event(key, current_user_id, description, metadata, object)
      MnoEnterprise::MnoHttparty.new.api_post('/audit_events', body: {
          key: key,
          user_id: current_user_id,
          description: description,
          metadata: metadata,
          subject_type: object.class.name,
          subject_id: object.id
      })
    end
  end
end
