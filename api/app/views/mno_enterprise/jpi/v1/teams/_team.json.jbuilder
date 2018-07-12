json.extract! team, :id, :name

json.users do
  json.array! team.users do |user|
    json.extract! user, :id, :name, :surname, :email
    json.role @parent_organization.role(user)
  end
end

json.app_instances do
  json.array! team.app_instances do |instance|
    json.extract! instance, :id, :name
    # Check if app is present as it is not needed for create/update actions
    json.logo instance.app.logo if instance.app
  end
end
