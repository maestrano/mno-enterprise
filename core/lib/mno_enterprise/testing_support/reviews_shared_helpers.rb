module MnoEnterprise::TestingSupport::ReviewsSharedHelpers

  REVIEW_ATTRIBUTES = %w(id description status user_id user_name organization_id organization_name app_id app_name user_admin_role edited edited_by_name edited_by_admin_role edited_by_id)

  def hash_for_review(review, attributes = REVIEW_ATTRIBUTES)
    review.attributes.slice(*attributes).merge({'created_at' => review.created_at.as_json, 'updated_at' => review.updated_at.as_json})
  end

  def hash_for_comment(comment, attributes = REVIEW_ATTRIBUTES)
    hash_for_review(comment, attributes).merge('feedback_id' => comment.parent_id)
  end

  def hash_for_feedback(feedback, attributes = REVIEW_ATTRIBUTES)
    hash_for_review(feedback, attributes).merge({'rating' => feedback.rating, 'comments' => feedback.comments.map { |c| hash_for_comment(c, attributes) }})
  end

  def hash_for_answer(answer, attributes = REVIEW_ATTRIBUTES)
    hash_for_review(answer, attributes).merge('question_id' => answer.parent_id)
  end

  def hash_for_question(question, attributes = REVIEW_ATTRIBUTES)
    hash_for_review(question, attributes).merge('answers' => question.answers.map { |c| hash_for_answer(c, attributes) })
  end

end
