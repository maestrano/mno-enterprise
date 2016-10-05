org = @parent_organization || team.organization
@all_apps ||= MnoEnterprise::App.all.to_a

json.id team.id
json.name team.name

json.users do
  json.array! team.users do |user|
    json.extract! user, :id, :name, :surname, :email
    json.role org.users.to_a.find { |e| e.id == user.id }.role
  end
end

json.app_instances do
  json.array! team.app_instances do |app_instance|
    json.id app_instance.id
    json.name app_instance.name

    if app = @all_apps.find { |e| e.id == app_instance.app_id }
      json.logo app.logo.to_s
    end
  end
end
