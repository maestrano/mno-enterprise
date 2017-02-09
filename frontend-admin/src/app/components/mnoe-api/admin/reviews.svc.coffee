# Service for managing the comments and reviews.
@App.service 'MnoeReviews', (MnoeAdminApiSvc, $log, toastr) ->
  _self = @

  # GET List /mnoe/jpi/v1/admin/app_reviews
  @list = () ->
    MnoeAdminApiSvc.all('app_reviews').getList().then(
      (response) ->
        response
      (error) ->
        # Display an error
        $log.error('Error while fetching reviews', error)
        toastr.error('An error occured while fetching the reviews.')
    )

  # UPDATE /mnoe/jpi/v1/admin/app_reviews/1
  @updateRating = (review) ->
    promise = MnoeAdminApiSvc.one('app_reviews', review.id).patch({status: review.status}).then(
      (response) ->
        response
      (error) ->
        # Display an error
        $log.error('Error while updating review', error)
        toastr.error('An error occured while updating the review.')
    )

  @updateDescription = (review) ->
    promise = MnoeAdminApiSvc.one('app_reviews', review.id).patch({description: review.description}).then(
      (response) ->
        response
      (error) ->
        # Display an error
        $log.error('Error while updating review', error)
        toastr.error('An error occured while updating the review.')
    )

  @replyQuestion = (id, replyText) ->
    promise = MnoeAdminApiSvc.all("/app_answers").post({question_id: id, app_answer: {description: replyText}}).then(
      (response) ->
        response
      (error) ->
        # Display an error
        $log.error('Error while updating review', error)
        toastr.error('An error occured while replying to question.')
    )

  @replyFeedback = (id, replyText) ->
    promise = MnoeAdminApiSvc.all("/app_comments").post({feedback_id: id, app_comment: {description: replyText}}).then(
      (response) ->
        response
      (error) ->
        # Display an error
        $log.error('Error while updating review', error)
        toastr.error('An error occured while replying to review.')
    )

  return @
