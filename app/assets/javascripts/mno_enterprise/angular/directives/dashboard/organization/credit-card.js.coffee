module = angular.module('maestrano.dashboard.dashboard-organization-credit-card',['maestrano.assets'])

#============================================
#
#============================================
module.controller('DashboardOrganizationCreditCardCtrl',[
  '$scope','$window','DhbOrganizationSvc', 'Utilities','AssetPath'
  ($scope, $window, DhbOrganizationSvc, Utilities,AssetPath) ->

    #====================================
    # Pre-Initialization
    #====================================
    $scope.assetPath = AssetPath
    $scope.isLoading = true
    $scope.forms = {}
    $scope.model = {}
    $scope.origModel = {}
    $scope.config = {
      validTitles: ['Mr.', 'Ms.', 'Mrs.', 'Miss', 'Dr.', 'Sir.', 'Prof.']
      validMonths: [1..12]
      validYears: [d = (new Date).getFullYear()..d+20]
      validCountries: $window.Countries
    }

    #====================================
    # Scope Management
    #====================================
    # Initialize the data used by the directive
    $scope.initialize = (creditCard) ->
      angular.copy(creditCard,$scope.model)
      angular.copy(creditCard,$scope.origModel)
      $scope.isLoading = false

    # Save the current state of the credit card
    $scope.save = ->
      $scope.isLoading = true
      DhbOrganizationSvc.billing.update($scope.model).then(
        (creditCard) ->
          $scope.errors = ''
          angular.copy(creditCard,$scope.model)
          angular.copy(creditCard,$scope.origModel)
          if $scope.callback
            $scope.callback()
        , (errors) ->
          $scope.errors = Utilities.processRailsError(errors)
      ).finally(-> $scope.isLoading = false)

    # Cancel the temporary changes made by the
    # user
    $scope.cancel = ->
      angular.copy($scope.origModel,$scope.model)
      $scope.errors = ''

    # Check if the user has started editing the
    # CreditCard
    $scope.isChanged = ->
      !angular.equals($scope.model,$scope.origModel)

    # Check whether we should display the cancel
    # button or not
    $scope.isCancelShown = ->
      $scope.isChanged()

    # Should we enable the save button
    $scope.isSaveEnabled = ->
      f = $scope.forms
      $scope.isChanged() && f.billingAddress.$valid && f.creditCard.$valid

    # Enable/Disable the credit card icons
    $scope.classForIconType = (ccType) ->
      self = $scope
      cType = self.getType()
      if ccType == self.getType() || cType == ""
        return "enabled"
      else
        return "disabled"

    # Return the credit card type (visa/mastercard/amex/jcb)
    $scope.getType = () ->
      self = $scope
      number = self.model.number
      if number != null && number != undefined
        re = new RegExp("^X");
        if (number.match(re) != null) then return ""

        re = new RegExp("^4");
        if (number.match(re) != null) then return "visa"

        re = new RegExp("^(34|37)");
        if (number.match(re) != null) then return "amex"

        re = new RegExp("^5[1-5]");
        if (number.match(re) != null) then return "mastercard"

        re = new RegExp("^6(?:011|5[0-9]{2})");
        if (number.match(re) != null) then return "discover"

        re = new RegExp("(?:2131|1800|35[0-9]{3})")
        if (number.match(re) != null) then return "jcb"

        re = new RegExp("^3(?:0[0-5]|[68][0-9])")
        if (number.match(re) != null) then return "dinersclub"

        # Last resort we assume that it is a Mastercard if
        # the number is long enough
        # See:
        #http://stackoverflow.com/questions/72768/how-do-you-detect-credit-card-type-based-on-number
        if number.length > 4
          return "mastercard"
        else
          return ""

      return ""

    # Open the godaddy site seal in a popup
    $scope.openGodaddySslSeal = () ->
      bgHeight = "779"
      bgWidth = "593"
      url = "https://seal.godaddy.com/verifySeal?sealID=RsNWG4eDd3ctNJWJfbeSBjJ6OWCtE3j0OwSXRDYF1WlMAGMqqmX5Kp"
      options = "menubar=no,toolbar=no,personalbar=no,location=yes,status=no,resizable=yes,fullscreen=no,scrollbars=no,width=#{bgWidth},height=#{bgHeight}"
      $window.open(url,'SealVerfication',options)

    #====================================
    # Post-Initialization
    #====================================
    $scope.$watch DhbOrganizationSvc.getId, (val) ->
      $scope.isLoading = true
      if val?
        DhbOrganizationSvc.load().then (organization)->
          $scope.initialize(organization.credit_card)
])

module.directive('dashboardOrganizationCreditCard', ['TemplatePath', (TemplatePath) ->
  return {
      restrict: 'A',
      scope: {
        callback:'&'
      },
      templateUrl: TemplatePath['mno_enterprise/dashboard/organization/credit-card.html'],
      controller: 'DashboardOrganizationCreditCardCtrl'
    }
])
