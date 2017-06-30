angular.module 'frontendAdmin'
.controller('AnswerEditModal', ($scope, $uibModalInstance, answer) ->

  $scope.answer = answer

  # Close the current modal
  $scope.closeModal = ->
    $uibModalInstance.dismiss()

  $scope.submitIteration = ->
    $uibModalInstance.close($scope.answer.description)

  return
)
