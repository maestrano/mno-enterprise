module = angular.module('maestrano.dashboard.dashboard-account',['maestrano.assets'])

#============================================
#
#============================================
module.controller('DashboardAccountCtrl',[
  '$scope','CurrentUserSvc','DashboardUser','Miscellaneous','Utilities',
  ($scope, CurrentUserSvc, DashboardUser, Miscellaneous, Utilities) ->
    CurrentUserSvc.loadDocument()
    CurrentUserSvc.then ->

      # Scope init
      $scope.countryCodes = Miscellaneous.countryCodes
      $scope.errors = {}
      $scope.success = {}
      # User model init
      $scope.isPersoInfoOpen = true
      userDocument = CurrentUserSvc.document.current_user
      $scope.user = { model: {}, password: {}, loading:false }

      setUserModel = (model) ->
        $scope.user.model = {
          name: model.name
          surname: model.surname
          email: model.email
          company: model.company
          phone: model.phone
          website: model.website
          phone_country_code: model.phone_country_code
        }
      if userDocument.deletionRequest
        $scope.user.currentDeletionRequestToken = userDocument.deletionRequest.token
      else
        $scope.user.currentDeletionRequestToken = -1

      setUserModel(userDocument)
      userOld = angular.copy($scope.user.model)

      $scope.user.hasChanged = ->
        !(_.isEqual($scope.user.model,userOld))

      $scope.user.cancelChanges = ->
        $scope.user.model = _.clone(userOld)

      $scope.user.update = ->
        $scope.user.loading = true
        CurrentUserSvc.update($scope.user.model).then(
          (userResp) ->
            # Email is not changed straight away - Notify user that new email will need to
            # be confirmed
            if userOld.email == $scope.user.model.email
              $scope.success.user = "Saved!"
            else
              $scope.success.user = "Saved! A confirmation email will be sent to your new email address. You will need to click on the link enclosed in this email in order to validate this new address."
            
            displayEmail = $scope.user.model.email
            console.log(userResp)
            setUserModel(userResp)

            # Email not changed in backend until confirmation
            # Keep changed email on frontend side to avoid user confusion
            $scope.user.model.email = displayEmail

            userOld = _.clone($scope.user.model)
            $scope.user.loading = false
          ,(error) ->
            $scope.user.loading = false
            $scope.errors.user = Utilities.processRailsError(error)
        )

      # ----------------------------------------------------
      # Password update
      # ----------------------------------------------------
      $scope.isChangePasswordOpen = false
      $scope.user.cancelPassword = ->
        $scope.user.password = { currentPassword:null, confirmPassword:null, newPassword:null }

      $scope.user.updatePasswordEnabled = ->
        $scope.user.password.currentPassword &&
        $scope.user.password.confirmPassword &&
        $scope.user.password.newPassword &&
        $scope.user.password.confirmPassword == $scope.user.password.newPassword


      $scope.user.cancelPasswordEnabled = ->
        $scope.user.password.currentPassword ||
        $scope.user.password.confirmPassword ||
        $scope.user.password.newPassword

      $scope.user.updatePassword = ->
        $scope.user.loading = true
        DashboardUser.updatePassword($scope.user.password.newPassword,$scope.user.password.confirmPassword,$scope.user.password.currentPassword).then(
          (success) ->
            $scope.user.loading = false
            $scope.success.changePassword = "Saved!"
          ,(error) ->
            $scope.user.loading = false
            $scope.errors.changePassword = Utilities.processRailsError(error)
        )

      # ----------------------------------------------------
      # Account Deletion
      # ----------------------------------------------------
      $scope.isAccountDeletionOpen = false
      $scope.user.createDeletionRequest = ->
        $scope.user.loading = true
        DashboardUser.deletionRequest().then(
          (success) ->
            $scope.user.loading = false
            $scope.user.currentDeletionRequestToken = success.data.token
          ,(error) ->
            $scope.user.loading = false
            $scope.errors.deletionReq = Utilities.processRailsError(error)
        )

      $scope.user.cancelDeletionRequest = ->
        if $scope.user.currentDeletionRequestToken
          $scope.user.loading = true
          token = $scope.user.currentDeletionRequestToken
          DashboardUser.cancelDeletionRequest(token).then(
            (success) ->
              $scope.user.loading = false
              $scope.user.currentDeletionRequestToken = -1
            ,(error) ->
              $scope.user.loading = false
              $scope.errors.deletionReq = Utilities.processRailsError(error)
          )

      $scope.user.resendDeletionRequest = ->
        if $scope.user.currentDeletionRequestToken
          $scope.user.loading = true
          token = $scope.user.currentDeletionRequestToken
          DashboardUser.resendDeletionRequest(token).then(
            (success) ->
              $scope.user.loading = false
            ,(error) ->
              $scope.user.loading = false
              $scope.errors.deletionReq = Utilities.processRailsError(error)
          )

      # TODO: nice to have: update the current user info the same way we updateds
      # apps info which will allow to remove the deletion request after 60 minutes

])

module.directive('dashboardAccount', ['TemplatePath', (TemplatePath) ->
  return {
      restrict: 'A',
      scope: {
      },
      templateUrl: TemplatePath['mno_enterprise/dashboard/account.html'],
      controller: 'DashboardAccountCtrl'
    }
])
