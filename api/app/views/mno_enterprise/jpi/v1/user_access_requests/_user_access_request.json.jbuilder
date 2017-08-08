json.extract! user_access_request, :id, :status, :created_at, :updated_at, :approved_at
json.requester do
  json.extract! user_access_request.requester, :id, :name, :surname
end

