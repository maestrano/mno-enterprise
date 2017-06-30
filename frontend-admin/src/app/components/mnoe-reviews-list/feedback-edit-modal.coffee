angular.module 'frontendAdmin'
.controller('FeedbackEditModal', ($scope, $uibModalInstance, review) ->

  $scope.feedback = review

  # Close the current modal
  $scope.closeModal = ->
    $uibModalInstance.dismiss()

  $scope.submitIteraction = ->
    $uibModalInstance.close($scope.feedback.description)

  return
)
