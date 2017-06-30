angular.module 'frontendAdmin'
.controller('QuestionReplyModal', ($scope, $uibModalInstance, question) ->

  $scope.replyText = ''

  $scope.question = question

  # Close the current modal
  $scope.closeModal = ->
    $uibModalInstance.dismiss()

  $scope.submitIteraction = ->
    $uibModalInstance.close($scope.replyText)

  return
)
