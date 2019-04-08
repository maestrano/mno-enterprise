json.extract! dashboard, :id, :name, :full_name, :currency

json.metadata dashboard.settings

json.data_sources dashboard.organizations.map do |org|
  json.id org.id
  json.uid org.uid
  json.label org.name
end

json.kpis dashboard.kpis, partial: 'mno_enterprise/jpi/v1/admin/impac/kpis/kpi', as: :kpi
json.widgets dashboard.widgets, partial: 'mno_enterprise/jpi/v1/admin/impac/widgets/widget', as: :widget
