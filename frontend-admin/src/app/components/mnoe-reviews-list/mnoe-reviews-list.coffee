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

    scope.openCommentEditModal = (comment) ->
      $uibModal.open(
        templateUrl: 'app/components/mnoe-reviews-list/comment-edit-modal.html'
        controller: 'CommentEditModal'
        resolve:
          comment: comment
      ).result.then(
        (response) ->
          console.log response
          MnoeReviews.updateComment(response).then(
            (response) ->
              console.log response
              # Remove the edit mode for this review
              #delete scope.editmode[review.id]
          )
      )

    scope.openFeedbackEditModal = (review) ->
      $uibModal.open(
        templateUrl: 'app/components/mnoe-reviews-list/feedback-edit-modal.html'
        controller: 'FeedbackEditModal'
        resolve:
          review: review
      ).result.then(
        (feedback) ->
          MnoeReviews.updateFeedback(review.id, feedback).then(
            (response) ->
              scope.listOfReviews.unshift(response.data.app_comment)
          )

      )

    scope.openAnswerEditModal = (answer) ->
      $uibModal.open(
        templateUrl: 'app/components/mnoe-reviews-list/answer-edit-modal.html'
        controller: 'AnswerEditModal'
        resolve:
          answer: answer
      ).result.then(
        (description) ->
          MnoeReviews.updateAnswer(answer.id, description).then(
            (response) ->
              scope.listOfReviews.unshift(response.data.app_comment)
          )

      )

    scope.openQuestionReplyModal = (question) ->
      $uibModal.open(
        templateUrl: 'app/components/mnoe-reviews-list/question-reply-modal.html'
        controller: 'QuestionReplyModal'
        resolve:
          question: question
      ).result.then(
        (replyText) ->
          MnoeReviews.replyQuestion(question.id, replyText).then(
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
