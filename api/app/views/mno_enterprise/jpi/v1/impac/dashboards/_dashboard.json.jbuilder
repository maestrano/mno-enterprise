json.extract! dashboard, :id, :full_name, :currency

json.metadata dashboard.settings

json.data_sources dashboard.organizations.compact.map do |org|
  json.id org.id
  json.uid org.uid
  json.label org.name
end
json.widgets dashboard.sorted_widgets, partial: 'mno_enterprise/jpi/v1/impac/widgets/widget', as: :widget
json.widgets_templates dashboard.filtered_widgets_templates
json.kpis dashboard.kpis, partial: 'mno_enterprise/jpi/v1/impac/kpis/kpi', as: :kpi
