json.id dashboard.id
json.name dashboard.name
json.full_name dashboard.full_name
json.data_sources dashboard.organizations.compact.map do |org|
  json.id org.id
  json.uid org.uid
  json.label org.name
end
json.widgets dashboard.sorted_widgets, partial: 'mno_enterprise/jpi/v1/impac/widgets/widget', as: :widget
json.widgets_templates dashboard.widgets_templates
json.kpis dashboard.kpis