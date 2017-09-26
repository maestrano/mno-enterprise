json.organizations do
  organizations = @import_report[:organizations]
  json.added do
    json.array! organizations[:added] do |o|
      json.partial! 'organization', organization: o
    end
  end
  json.updated do
    json.array! organizations[:updated] do |o|
      json.partial! 'organization', organization: o
    end
  end
end
json.users do
  users = @import_report[:users]
  json.added do
    json.array! users[:added] do |u|
      json.partial! 'mno_enterprise/jpi/v1/admin/users/user', user: u
    end
  end
  json.updated do
    json.array! users[:updated] do |u|
      json.partial! 'mno_enterprise/jpi/v1/admin/users/user', user: u
    end
  end
end









