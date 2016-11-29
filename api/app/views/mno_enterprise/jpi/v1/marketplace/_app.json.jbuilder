json.extract! app, :id, :nid, :name, :stack, :key_benefits, :categories, :tags, :tiny_description,
              :testimonials, :pictures, :pricing_plans, :rank

json.description markdown(app.sanitized_description)

json.is_responsive app.responsive?
json.is_star_ready app.star_ready?
json.is_connec_ready app.connec_ready?
json.is_coming_soon app.coming_soon?
json.single_billing app.single_billing?
json.multi_instantiable app.multi_instantiable
json.subcategories app.subcategories
json.average_rating app.average_rating

if app.logo
  json.logo app.logo.to_s
end

if app.ratings
  json.ratings app.ratings do |app_user_rating|
    json.id app_user_rating[:id]
    json.rating app_user_rating[:rating]
    json.description app_user_rating[:description]
    json.status app_user_rating[:status]
    json.user_id app_user_rating[:user_id]
    json.user_name app_user_rating[:user_name]
    json.organization_id app_user_rating[:organization_id]
    json.organization_name app_user_rating[:organization_name]
    json.app_id app_user_rating[:app_id]
    json.app_name app_user_rating[:app_name]
    json.created_at app_user_rating[:created_at]
    json.updated_at app_user_rating[:updated_at]
  end
end


