json.extract! audit_event, :id, :key, :user_id, :description, :created_at, :user

if audit_event.details.is_a? String
  json.details audit_event.details
end
