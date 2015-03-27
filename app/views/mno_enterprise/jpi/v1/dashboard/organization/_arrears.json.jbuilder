arrears_situations ||= @organization.arrears_situations.in_progress

json.arrears_situations do
  json.array! [arrears_situations].flatten do |sit|
    json.id sit.id
    json.owner_id sit.owner_id
    json.owner_type sit.owner_type
    json.category sit.category
    json.status sit.status
  end
end