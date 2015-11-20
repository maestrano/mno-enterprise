json.id team.id
json.name team.name

json.users do
  json.array! team.users do |user|
    json.extract! user, :id, :name, :surname, :email
    json.role user.role(team.organization)
  end
end

json.app_instances do
  json.array! team.app_instances do |app_instance|
    json.id app_instance.id
    json.name app_instance.name
    
    if app_instance.app
      json.logo app_instance.app.logo.to_s
    end
  end
end