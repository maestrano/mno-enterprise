# Fully qualify template path to allow concern to be included in different modules
json.array! @dashboards, partial: 'mno_enterprise/jpi/v1/impac/dashboards/dashboard', as: :dashboard
