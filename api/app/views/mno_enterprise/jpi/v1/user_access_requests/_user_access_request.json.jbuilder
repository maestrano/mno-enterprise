json.extract! user_access_request, :id, :status, :created_at, :updated_at, :approved_at, :expiration_date, :current_status
if user_access_request.requester
  json.requester do
    json.extract! user_access_request.requester, :id, :name, :surname
  end
end
