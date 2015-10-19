json.id app.id
json.nid app.nid
json.name app.name
json.stack app.stack
json.key_benefits app.key_benefits
json.categories app.categories
json.tags app.tags

json.is_responsive app.responsive?
json.is_star_ready app.star_ready?
json.is_connec_ready app.connec_ready?
json.tiny_description app.tiny_description
json.description markdown(app.sanitized_description)
json.testimonials app.testimonials
json.pictures app.pictures

if app.logo
  json.logo app.logo.to_s
end
