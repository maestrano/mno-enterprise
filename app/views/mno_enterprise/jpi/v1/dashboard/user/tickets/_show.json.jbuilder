ticket ||= @ticket

json.id ticket.id
json.subject ticket.subject
json.description ticket.description
json.created_at ticket.created_at
json.status ticket.status
json.comments do
  json.array! ticket.comments do |comment|
    json.partial! 'comment', comment: comment
  end
end
