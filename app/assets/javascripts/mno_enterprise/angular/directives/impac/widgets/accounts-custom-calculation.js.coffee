module = angular.module('maestrano.impac.widgets.accounts.custom-calculation',['maestrano.assets'])

module.controller('WidgetAccountsCustomCalculationCtrl',[
  '$scope', '$timeout', '$modal', 'ImpacDashboardingSvc', 'TemplatePath', 'AssetPath',
  ($scope, $timeout, $modal, ImpacDashboardingSvc, TemplatePath, AssetPath) ->

    w = $scope.widget

    $scope.loaderImage = AssetPath['mno_enterprise/loader-32x32-bg-inverse.gif']

    w.initContext = ->
      $scope.movedAccount = {}
      $scope.isDataFound = w.content? && !_.isEmpty(w.content.complete_list) && w.content.formula?

    getSelectedOrganizations = ->
      return w.selectedOrganizations

    # Reload the accounts lists on organizations list change
    $scope.$watch getSelectedOrganizations, (result) ->
      w.updateSettings(false) if !_.isEmpty(result)
    ,true

    # #====================================
    # # Formula management
    # #====================================

    $scope.addAccountToFormula = (account) ->
      # When some accounts are already in savedList
      if w.savedList.length > 0
        w.formula += " + {#{w.savedList.length + 1}}"
      # Otherwise
      else
        w.formula = "{1}"

      # Will trigger updateSettings()
      w.moveAccountToAnotherList(account,w.completeList,w.savedList)

    $scope.removeAccountFromFormula = (account) ->
      prevUids = _.map(w.savedList, (e) ->
        e.uid
      )
      nextUids = _.reject(prevUids, (e) ->
        e == account.uid
      )

      diffAccountUid = _.first(_.difference(prevUids,nextUids))
      diffAccountIndex = _.indexOf(prevUids, diffAccountUid) + 1
      
      if diffAccountIndex == 1
        # We remove the next operator
        removePattern = "{#{diffAccountIndex}\\}\\s*(-|\\*|\\/|\\+)*\\s*"
      else
        # We remove the previous operator
        removePattern = "\\s*(-|\\*|\\/|\\+)*\\s*\\{#{diffAccountIndex}\\}"
      newFormula = angular.copy(w.formula).replace(new RegExp(removePattern, 'g'),'')
      
      # We downgrade all the next indexes
      i = diffAccountIndex + 1
      while i <= prevUids.length
        indexPattern = "\\{#{i}\\}"
        newFormula = newFormula.replace(new RegExp(indexPattern, 'g'), "{#{i-1}}")
        i++

      w.formula = angular.copy(newFormula)
      # Will trigger updateSettings()
      w.moveAccountToAnotherList(account,w.savedList,w.completeList)

    #====================================
    # Modal management
    #====================================

    $scope.formulaModal = {}
    $scope.formulaModal.config = {
      instance: {
        backdrop: 'static'
        templateUrl: TemplatePath['mno_enterprise/impac/modals/formula-modal.html']
        size: 'lg'
        scope: $scope
        keyboard: false
      }
    }

    $scope.formulaModal.open = ->
      # A new organization setting directive is going to be inserted via the modal
      # before loading it, we remove the initial setting
      w.settings = angular.copy(_.reject w.settings, (elem) ->
        elem.key == "organizations"
      )
      self = $scope.formulaModal
      self.$instance = $modal.open(self.config.instance)
      $timeout ->
        w.initSettings(false)
      ,200

    $scope.formulaModal.cancel = ->
      w.initSettings()
      $scope.formulaModal.close()

    $scope.formulaModal.proceed = ->
      w.updateSettings()
      $scope.formulaModal.close()
    
    $scope.formulaModal.close = ->
      $scope.formulaModal.$instance.close()

    getEditMode = ->
      return w.isEditMode

    # Open the modal on toogleEditMode()
    $scope.$watch getEditMode, (result, prev) ->
      if result && !prev
        $scope.formulaModal.open()


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
      w.loadContent() if total == 3

    return w
])

module.directive('widgetAccountsCustomCalculation', ->
  return {
    restrict: 'A',
    link: (scope, element) ->
      element.addClass("accounts")
      element.addClass("custom-calculation")
    ,controller: 'WidgetAccountsCustomCalculationCtrl'
  }
)