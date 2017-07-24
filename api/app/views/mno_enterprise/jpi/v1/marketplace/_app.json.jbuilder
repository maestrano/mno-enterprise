json.extract! app, :id, :nid, :name, :stack, :key_benefits, :categories, :tags, :tiny_description,
  :testimonials, :pictures, :pricing_plans, :rank, :support_url, :key_workflows, :key_features, :pricing_text

json.description markdown(app.sanitized_description)
json.known_limitations markdown(app.known_limitations)
json.getting_started markdown(app.getting_started)

json.is_responsive app.responsive?
json.is_star_ready app.star_ready?
json.is_connec_ready app.connec_ready?
json.is_coming_soon app.coming_soon?
json.single_billing app.single_billing?
json.multi_instantiable app.multi_instantiable
json.subcategories app.subcategories
json.average_rating app.average_rating
json.add_on app.add_on?
json.running_instances_count app.running_instances_count

if app.app_shared_entities.any?
  json.app_shared_entities do
    json.array! app.app_shared_entities do |shared_entity|
      json.shared_entity_nid shared_entity.shared_entity.nid
      json.shared_entity_name shared_entity.shared_entity&.name
      json.shared_entity_name shared_entity.shared_entity&.name
      json.write shared_entity.write
      json.read shared_entity.read
    end
  end
end

if app.logo
  json.logo app.logo.to_s
end
