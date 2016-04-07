json.extract! dashboard, :id, :name, :full_name, :widgets_templates, :currency

json.data_sources dashboard.organizations.compact.map do |org|
  json.id org.id
  json.uid org.uid
  json.label org.name
end
json.widgets dashboard.filtered_widgets_templates, partial: 'mno_enterprise/jpi/v1/impac/widgets/widget', as: :widget
json.kpis dashboard.kpis, partial: 'mno_enterprise/jpi/v1/impac/kpis/kpi', as: :kpi
