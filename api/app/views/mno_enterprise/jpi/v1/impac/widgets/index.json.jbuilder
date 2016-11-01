json.widgets @widgets.map do |widget|
  json.extract! widget, :id, :endpoint, :settings
end
