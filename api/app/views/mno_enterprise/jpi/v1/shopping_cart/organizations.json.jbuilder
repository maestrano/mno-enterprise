json.array! @orgs do |org|
  json.id org.id
  json.name org.name
  json.role current_user.role(org)
end