module = angular.module('maestrano.dashboard.dashboard-organization-arrears',['maestrano.assets'])

#============================================
# Arrears Directive
#============================================
module.controller('DashboardOrganizationArrearsCtrl',[
  '$scope','$window','DhbOrganizationSvc', 'Utilities','AssetPath'
  ($scope, $window, DhbOrganizationSvc, Utilities,AssetPath) ->
    #====================================
    # Pre-Initialization
    #====================================
    $scope.assetPath = AssetPath
    $scope.isLoading = true
    $scope.paymentFailedBox = paymentFailedBox = {}
    $scope.situations = {}

    DhbOrganizationSvc.load().then (organization)->
      $scope.situations = organization.arrears_situations
      $scope.isLoading = false

    #==============================
    # Payment failed/retry section
    #==============================
    paymentFailedBox.errors = []
    paymentFailedBox.inProgress = false

    paymentFailedBox.getSituation = () ->
      _.find($scope.situations,
        (situation) -> situation.category == 'payment_failed'
      )

    paymentFailedBox.show = ->
      this.getSituation()?

    paymentFailedBox.retryPayment = () ->
      self = this
      self.inProgress = true
      DhbOrganizationSvc.charge().then (response) ->
        success = response.status == 'success'
        payment = response.data
        if (payment)
          if (success)
            self.resolve()
          else if (payment.full_return_message)
            self.errors = Utilities.processRailsError(payment.full_return_message)
          else
            self.errors = Utilities.processRailsError("bug")
        else
          self.errors = Utilities.processRailsError("bug")
        self.inProgress = false

    paymentFailedBox.resolve = () ->
      self = this
      # Remove ArrearsSituation
      index = $scope.situations.indexOf(self.getSituation())
      $scope.situations.splice(index,1)
      # Return success
      self.success = "Thank you! The payment has been performed successfully!"

])

module.directive('dashboardOrganizationArrears', ['TemplatePath', (TemplatePath) ->
  return {
      restrict: 'A',
      scope: {
      },
      templateUrl: TemplatePath['dashboard/organization/arrears.html'],
      controller: 'DashboardOrganizationArrearsCtrl'
    }
])