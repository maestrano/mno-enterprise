json.added_organizations do
  json.array! @added_organizations do |o|
    json.partial! 'organization', organization: o
  end
end

json.updated_organizations do
  json.array! @updated_organizations do |o|
    json.partial! 'organization', organization: o
  end
end

json.added_users do
  json.array! @added_users do |u|
    json.partial! 'mno_enterprise/jpi/v1/admin/users/user', user: u
  end
end

json.updated_users do
  json.array! @updated_users do |u|
    json.partial! 'mno_enterprise/jpi/v1/admin/users/user', user: u
  end
end



