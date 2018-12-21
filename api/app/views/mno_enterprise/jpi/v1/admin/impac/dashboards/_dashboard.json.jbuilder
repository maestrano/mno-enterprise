json.extract! dashboard, :id, :name, :full_name, :currency

json.metadata dashboard.settings

# :created_at, :updated_at, :settings

json.data_sources dashboard.organizations.map do |org|
  json.id org.id
  json.uid org.uid
  json.label org.name
end

# TODO: use if nested?
json.widgets dashboard.widgets, partial: 'mno_enterprise/jpi/v1/admin/impac/widgets/widget', as: :widget

# json.kpis dashboard.kpis, partial: 'mno_enterprise/jpi/v1/impac/kpis/kpi', as: :kpi
# json.widgets dashboard.widgets, partial: 'mno_enterprise/jpi/v1/impac/widgets/widget', as: :widget
# json.widgets_templates dashboard.filtered_widgets_templates

# json.kpis template.kpis, partial: 'mno_enterprise/jpi/v1/admin/impac/kpis/kpi', as: :kpi
# json.widgets template.widgets, partial: 'mno_enterprise/jpi/v1/admin/impac/widgets/widget', as: :widget
#
# json.created_at template.created_at
# json.updated_at template.updated_at
# json.published template.published
