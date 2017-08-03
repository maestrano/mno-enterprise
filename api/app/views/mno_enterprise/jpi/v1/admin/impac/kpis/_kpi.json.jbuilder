json.ignore_nil!
json.extract! kpi, :id, :element_watched, :endpoint, :source, :targets, :settings, :extra_watchables, :extra_params
json.alerts []
