module = angular.module('maestrano.impac.widgets.invoices.summary',['maestrano.assets'])

module.controller('WidgetInvoicesSummaryCtrl',[
  '$scope', 'ImpacDashboardingSvc', 'Utilities', 'ImpacChartFormatterSvc',
  ($scope, ImpacDashboardingSvc, Utilities, ImpacChartFormatterSvc) ->

    w = $scope.widget

    w.initContext = ->
      $scope.isDataFound = !_.isEmpty(w.content.summary)

    w.format = ->
      if $scope.isDataFound
        pieData = _.map w.content.summary, (entity) ->
          {
            label: entity.label,
            value: entity.total,
          }
        pieOptions = {
          percentageInnerCutout: 50,
          tooltipFontSize: 12,
        }
        w.chart = ImpacChartFormatterSvc.pieChart(pieData, pieOptions)

    # No need to put this under initContext because it won't change after a settings update
    w.entityType = w.metadata.entity
    # Not used at this moment, but could be used if we propose other chart (top unpaid, etc..)
    if w.metadata.order_by == 'name' || w.metadata.order_by == 'total_invoiced'
      $scope.orderBy = ''
    else  
      # returned by Impac!: "total_something"
      $scope.orderBy = _.last(w.metadata.order_by.split('_')).concat(" ")


    # TODO: Refactor once we have understood exactly how the angularjs compilation process works:
    # in this order, we should:
    # 1- compile impac-widget controller
    # 2- compile the specific widget template/controller
    # 3- compile the settings templates/controllers
    # 4- call widget.loadContent() (ideally, from impac-widget, once a callback 
    #     assessing that everything is compiled an ready is received)
    getSettingsCount = ->
      if w.settings?
        return w.settings.length
      else
        return 0

    $scope.$watch getSettingsCount, (total) ->
      w.loadContent() if total == 2

    return w
])

module.directive('widgetInvoicesSummary', ->
  return {
    restrict: 'A',
    link: (scope, element) ->
      element.addClass("invoices")
      element.addClass("summary")
    ,controller: 'WidgetInvoicesSummaryCtrl'
  }
)