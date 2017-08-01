json.ignore_nil!
json.extract! kpi, :id, :element_watched, :endpoint, :source, :targets, :settings, :extra_watchables, :extra_params

json.alerts kpi.alerts, partial: 'mno_enterprise/jpi/v1/impac/alerts/alert', as: :alert if kpi.alerts.to_a.any?
