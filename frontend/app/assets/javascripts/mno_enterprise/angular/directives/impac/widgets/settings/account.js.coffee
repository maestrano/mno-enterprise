module = angular.module('maestrano.impac.widgets.settings.account',['maestrano.assets'])

module.controller('WidgetSettingAccountCtrl', ['$scope', ($scope) ->

  w = $scope.parentWidget

  # What will be passed to parentWidget
  setting = {}
  setting.key = "account"
  setting.isInitialized = false

  # initialization of time range parameters from widget.content.hist_parameters
  setting.initialize = ->
    w.selectedAccount = null
    if w.content? 
      if w.content.account_list? && w.content.account_uid?
        w.selectedAccount = _.find(w.content.account_list, (acc) ->
          acc.uid == w.content.account_uid
        )
        setting.isInitialized = true

  setting.toMetadata = ->
    if w.selectedAccount? 
      return { account_uid: w.selectedAccount.uid }
    else
      return { account_uid: null }

  w.settings ||= []
  w.settings.push(setting)
])

module.directive('widgetSettingAccount', ['TemplatePath', (TemplatePath) ->
  return {
    restrict: 'A',
    scope: {
      parentWidget: '='
    },
    templateUrl: TemplatePath['mno_enterprise/impac/widgets/settings/account.html'],
    controller: 'WidgetSettingAccountCtrl'
  }
])