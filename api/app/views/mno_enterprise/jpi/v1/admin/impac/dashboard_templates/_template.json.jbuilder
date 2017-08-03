json.extract! template, :id, :name, :full_name, :currency

json.metadata template.settings

json.data_sources template.organizations(current_user.organizations).compact.map do |org|
  json.id org.id
  json.uid org.uid
  json.label org.name
end

json.kpis template.kpis, partial: 'mno_enterprise/jpi/v1/admin/impac/kpis/kpi', as: :kpi
json.widgets template.widgets, partial: 'mno_enterprise/jpi/v1/admin/impac/widgets/widget', as: :widget

json.created_at template.created_at
json.updated_at template.updated_at
