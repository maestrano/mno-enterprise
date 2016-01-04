json.audit_events do
  json.array! @audit_events, partial: 'audit_event', as: :audit_event
end
json.metadata @audit_events.metadata