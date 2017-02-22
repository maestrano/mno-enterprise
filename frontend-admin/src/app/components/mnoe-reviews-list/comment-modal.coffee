angular.module 'frontendAdmin'
.controller('CommentModal', ($scope, $uibModalInstance) ->

  $scope.commentText = ''

  # Close the current modal
  $scope.closeModal = ->
    $uibModalInstance.dismiss()

  $scope.submitIteraction = ->
    $uibModalInstance.dismiss()

  return
)
