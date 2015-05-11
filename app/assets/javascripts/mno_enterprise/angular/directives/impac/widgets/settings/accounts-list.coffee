module = angular.module('maestrano.impac.widgets.settings.accounts-list',['maestrano.assets'])

# There is no template associated to this setting, and though it won't appear in the 'settings' panel
# However, as its metadata has to be initialized from, and saved to Impac!, we build ListAccounts as a setting
module.controller('WidgetSettingAccountsListCtrl', ['$scope', ($scope) ->

  # ---------------------------------------------------------
  # ### Populate the widget
  # ---------------------------------------------------------

  w = $scope.parentWidget

  # Used by the 'delete' button in the accounts list and by the comboBox
  w.moveAccountToAnotherList = (account, src, dst) ->
    removeAccountFromList(account, src)
    addAccountToList(account, dst)
    # semi-discreet update of the Impac! object
    # w.isChartLoading = true
    w.updateSettings(false)

  # ---------------------------------------------------------
  # ### Helpers
  # ---------------------------------------------------------

  removeAccountFromList = (account, list) ->
    if !_.isEmpty(list)
      angular.copy _.reject(list, (accInList) ->
        account.uid == accInList.uid
      ), list

  addAccountToList = (account, list) ->
    if account?
      list ||= []
      list.push(account)

  # ---------------------------------------------------------
  # ### Setting definition
  # ---------------------------------------------------------

  setting = {}
  setting.key = "accounts-list"
  setting.isInitialized = false

  setting.initialize = ->
    w.completeList = []
    w.savedList = []
    if w.content? && !_.isEmpty(w.content.complete_list)
      w.completeList = angular.copy(w.content.complete_list)
      if !_.isEmpty(w.content.saved_list)
        w.savedList = angular.copy(w.content.saved_list)
        # Impac! returns the list of all the accounts, and we want that:
        # completeList + savedList = list of all accounts
        angular.forEach(w.savedList, (account) ->
          removeAccountFromList(account,w.completeList)
        )
      setting.isInitialized = true

  setting.toMetadata = ->
    return { account_list: w.savedList }

  w.settings ||= []
  w.settings.push(setting)
])

module.directive('widgetSettingAccountsList', ['TemplatePath', (TemplatePath) ->
  return {
    restrict: 'A',
    scope: {
      parentWidget: '='
    },
    controller: 'WidgetSettingAccountsListCtrl'
  }
])