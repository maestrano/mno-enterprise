json.extract! dashboard_template, :id, :name, :full_name, :currency, :created_at, :updated_at

json.metadata dashboard_template.settings

json.data_sources dashboard_template.organizations(current_user.organizations).compact.map do |org|
  json.id org.id
  json.uid org.uid
  json.label org.name
end
