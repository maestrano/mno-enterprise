module = angular.module('maestrano.impac.widgets.accounts.balance',['maestrano.assets'])

module.controller('WidgetAccountsBalanceCtrl',[
  '$scope', 'ImpacDashboardingSvc', 'ImpacChartFormatterSvc',
  ($scope, ImpacDashboardingSvc, ImpacChartFormatterSvc) ->

    w = $scope.widget
    $scope.hideTimeRange = true

    hasAnAccountSelected = ->
      w.selectedAccount?

    getEditMode = ->
      w.isEditMode

    w.initContext = ->
      $scope.isDataFound = w.content? && w.content.account_list?

    w.format = ->
      if $scope.isDataFound && hasAnAccountSelected()
        data = angular.copy(w.selectedAccount)
        inputData = {title: data.name, labels: w.content.dates, values: data.balances}
        all_values_are_positive = true
        angular.forEach(data.balances, (value) ->
          all_values_are_positive &&= value >= 0
        )

        options = {
          scaleBeginAtZero: all_values_are_positive,
          showXLabels: false,
        }
        w.chart = ImpacChartFormatterSvc.lineChart([inputData],options)

    $scope.getName = ->
      w.selectedAccount.name if hasAnAccountSelected()

    $scope.getCurrentBalance = ->
      w.selectedAccount.current_balance if hasAnAccountSelected()

    $scope.getCurrency = ->
      w.selectedAccount.currency if hasAnAccountSelected()

    $scope.$watch hasAnAccountSelected, (result,prev) ->
      # When no account is selected
      # we force the edit mode and we hide the time range setting
      if !result
        $scope.hideTimeRange = true
        w.isEditMode = true
      # When an account is selected
      # we display the time range setting
      else
        $scope.hideTimeRange = false
        # When an account is selected for the first time
        # we exit the edit mode and - discreet - update the settings
        if !prev
          w.isEditMode = false
          w.isHistMode = false
          w.updateSettings(false)

    # When the user tries to disable edit mode without having selected an account
    # we force the edit mode to remain enabled
    $scope.$watch getEditMode, (result) ->
      w.isEditMode = true if !hasAnAccountSelected()
        

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
      w.loadContent() if total == 4

    return w
])

module.directive('widgetAccountsBalance', ->
  return {
    restrict: 'A',
    link: (scope, element) ->
      element.addClass("accounts")
      element.addClass("balance")
    ,controller: 'WidgetAccountsBalanceCtrl'
  }
)