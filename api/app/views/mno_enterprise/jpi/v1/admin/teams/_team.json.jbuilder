json.id team.id
json.name team.name

json.users do
  json.array! team.users do |user|
    json.extract! user, :id, :name, :surname, :email
    json.role @parent_organization.role(user)
  end
end

json.app_instances do
  json.array! team.app_instances do |app_instance|
    json.extract! app_instance, :id, :name
    json.logo app_instance&.app.logo&.to_s
  end
end
