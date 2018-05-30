@all_apps ||= MnoEnterprise::App.all.to_a
@all_products ||= MnoEnterprise::Product.all.to_a

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
    json.id product_instance.id
    json.name product_instance.name

    if product = @all_products.find { |e| e.id == product_instance.product_id }
      json.logo product.logo.to_s
    end
  end
end
