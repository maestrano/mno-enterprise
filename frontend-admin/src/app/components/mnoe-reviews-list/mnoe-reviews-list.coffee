@App.directive('mnoeReviewsList', ($filter, $log, $uibModal, MnoeReviews) ->
  restric:'E'
  scope: {
  }
  templateUrl:'app/components/mnoe-reviews-list/mnoe-reviews-list.html'
  link: (scope) ->

    scope.editmode = []
    scope.listOfReviews = []
    scope.statuses = ['approved', 'rejected']

    #====================================
    # Comment modal
    #====================================
    scope.openCommentModal = () ->
      $uibModal.open(
        templateUrl: 'app/components/mnoe-reviews-list/comment-modal.html'
        controller: 'CommentModal'
      )

    scope.openEditModal = (review) ->
      $uibModal.open(
        templateUrl: 'app/components/mnoe-reviews-list/comment-edit-modal.html'
        controller: 'CommentEditModal'
        resolve:
          review: review
      ).result.then(
        (review) ->
          MnoeReviews.updateDescription(review).then(
            (response) ->
              console.log(response);
              # Remove the edit mode for this review
              #delete scope.editmode[review.id]
          )

      )

    scope.openFeedbackReplyModal = (review) ->
      $uibModal.open(
        templateUrl: 'app/components/mnoe-reviews-list/feedback-reply-modal.html'
        controller: 'FeedbackReplyModal'
      ).result.then(
        (replyText) ->
          MnoeReviews.replyFeedback(review.id, replyText).then(
            (response) ->
              scope.listOfReviews.unshift(response.data.app_comment)
          )

      )

    scope.openQuestionReplyModal = (review) ->
      $uibModal.open(
        templateUrl: 'app/components/mnoe-reviews-list/question-reply-modal.html'
        controller: 'QuestionReplyModal'
      ).result.then(
        (replyText) ->
          MnoeReviews.replyQuestion(review.id, replyText).then(
            (response) ->
              scope.listOfReviews.unshift(response.data.app_answer)
          )

      )

    fetchReviews = () ->
      return MnoeReviews.list().then(
        (response) ->
          scope.listOfReviews = response.data
      )

    scope.update = (review) ->
      MnoeReviews.updateRating(review).then(
        (response) ->
          # Remove the edit mode for this review
          delete scope.editmode[review.id]
      )

    fetchReviews()
    return
)
