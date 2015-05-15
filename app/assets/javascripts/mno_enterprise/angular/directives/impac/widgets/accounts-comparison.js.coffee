module = angular.module('maestrano.impac.widgets.accounts.comparison',['maestrano.assets'])

module.controller('WidgetAccountsComparisonCtrl',[
  '$scope', 'ImpacDashboardingSvc', 'ImpacChartFormatterSvc',
  ($scope, ImpacDashboardingSvc, ImpacChartFormatterSvc) ->

    $scope.isChartLoading = false

    w = $scope.widget

    w.initContext = ->
      $scope.isDataFound = w.content? && !_.isEmpty(w.content.complete_list)
      $scope.movedAccount = {}

    w.format = ->
      inputData = {labels: [], values: []}
      _.map w.savedList, (account) ->
        inputData.labels.push account.name
        inputData.values.push account.current_balance_no_format
      while inputData.values.length < 15
        inputData.labels.push ""
        inputData.values.push null

      options = {
        showTooltips: false,
        showXLabels: false,
        barDatasetSpacing: 9,
      }
      w.chart = ImpacChartFormatterSvc.barChart(inputData,options)

    $scope.getAccountColor = (anAccount) ->
      ImpacChartFormatterSvc.getColor(_.indexOf(w.savedList, anAccount))

    $scope.addAccount = (anAccount) ->
      w.moveAccountToAnotherList(anAccount,w.completeList,w.savedList)
      w.format()

    $scope.removeAccount = (anAccount) ->
      w.moveAccountToAnotherList(anAccount,w.savedList,w.completeList)
      w.format()


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

module.directive('widgetAccountsComparison', ->
  return {
    restrict: 'A',
    link: (scope, element) ->
      element.addClass("accounts")
      element.addClass("comparison")
    ,controller: 'WidgetAccountsComparisonCtrl'
  }
)