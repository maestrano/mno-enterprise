json.extract! dashboard, :id, :name, :created_at, :updated_at, :settings

json.kpis do
  json.array! dashboard.kpis, partial: 'kpi', as: :kpi
end

json.widgets do
  json.array! dashboard.widgets, partial: 'widget', as: :widget
end
