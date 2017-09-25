json.added_organizations do
  json.array! @import_report[:organizations][:added] do |o|
    json.partial! 'organization', organization: o
  end
end

json.updated_organizations do
  json.array! @import_report[:organizations][:updated] do |o|
    json.partial! 'organization', organization: o
  end
end

json.added_users do
  json.array! @import_report[:users][:added] do |u|
    json.partial! 'mno_enterprise/jpi/v1/admin/users/user', user: u
  end
end

json.updated_users do
  json.array! @import_report[:users][:updated] do |u|
    json.partial! 'mno_enterprise/jpi/v1/admin/users/user', user: u
  end
end



