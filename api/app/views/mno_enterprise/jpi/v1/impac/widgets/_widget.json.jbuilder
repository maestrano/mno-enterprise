json.id widget.id
json.name widget.name
json.endpoint (widget.endpoint || widget.widget_category)
json.width widget.width
json.metadata widget.settings
json.owner widget.dashboard_owner_uid

json.kpis widget.kpis, partial: 'mno_enterprise/jpi/v1/impac/kpis/kpi', as: :kpi
