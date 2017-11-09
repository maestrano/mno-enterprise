json.ignore_nil!
json.extract! alert, :id, :title, :webhook, :service, :sent, :kpi_id
json.metadata alert.settings
json.recipients alert.recipients.map do |recipient|
  json.extract! recipient, :id, :email
end
