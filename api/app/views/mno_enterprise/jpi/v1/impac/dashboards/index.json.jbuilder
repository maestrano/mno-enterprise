json.array! @dashboards  do |dashboard|
  json.extract! dashboard, :id, :name, :full_name, :currency
  json.data_sources dashboard.organizations(current_user.organizations).compact.map do |org|
    json.id org.id
    json.uid org.uid
    json.label org.name
  end
end
