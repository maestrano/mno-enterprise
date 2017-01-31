json.ignore_nil!
json.extract! alert, :id, :title, :webhook, :service, :sent, :recipients
json.metadata alert.settings
json.kpi_id alert.impac_kpi_id
