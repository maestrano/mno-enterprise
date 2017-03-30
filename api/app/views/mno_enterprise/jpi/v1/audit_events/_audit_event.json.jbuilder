json.extract! audit_event, :id, :key, :user_id, :description, :created_at, :user

if audit_event.formatted_details.present?
  json.details audit_event.formatted_details
end
