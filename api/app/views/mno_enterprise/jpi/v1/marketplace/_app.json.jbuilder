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

json.reviews app.reviews do |app_review|
  json.partial! 'app_review', app_review: app_review
end
