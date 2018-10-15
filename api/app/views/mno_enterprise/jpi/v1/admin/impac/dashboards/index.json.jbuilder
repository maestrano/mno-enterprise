json.dashboards do
  json.array! @dashboards, partial: 'dashboard', as: :dashboard
end
