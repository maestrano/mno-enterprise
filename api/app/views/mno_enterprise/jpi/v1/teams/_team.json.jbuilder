@all_apps ||= MnoEnterprise::App.all.to_a

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
    json.id app_instance.id
    json.name app_instance.name

    if app = @all_apps.find { |e| e.id == app_instance.app_id }
      json.logo app.logo.to_s
    end
  end
end

json.product_instances do
  json.array! team.product_instances do |product_instance|
    json.extract! product_instance, :id, :name
    json.logo product_instance&.product.logo&.to_s
  end
end
