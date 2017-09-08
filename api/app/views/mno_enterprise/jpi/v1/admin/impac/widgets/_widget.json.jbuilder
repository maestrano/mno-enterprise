json.id widget.id
json.name widget.name
json.endpoint (widget.endpoint || widget.widget_category)
json.width widget.width
json.metadata widget.settings

json.kpis widget.kpis, partial: 'mno_enterprise/jpi/v1/admin/impac/kpis/kpi', as: :kpi
