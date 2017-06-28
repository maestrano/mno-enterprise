json.extract! audit_event, :id, :key, :user_id, :description, :created_at
json.user do
  json.extract! audit_event.user, :id, :uid, :email, :phone, :name, :surname
end if audit_event.user
json.organization do
  json.extract! audit_event.organization , :id, :name, :uid
end if audit_event.organization


if audit_event.formatted_details.present?
  json.details audit_event.formatted_details
end
