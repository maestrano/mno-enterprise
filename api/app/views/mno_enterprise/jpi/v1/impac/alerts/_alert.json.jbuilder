json.ignore_nil!
json.extract! alert, :id, :title, :webhook, :service, :metadata, :sent
json.kpi_id alert.impac_kpi_id
json.recipients alert.recipients.map do |recipient|
  json.extract! recipient, :id, :email
end
