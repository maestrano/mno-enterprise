if app_question
  json.partial! 'app_review', app_review: app_question, show_rating: false

  json.answers do
    json.array! app_question.answers do |app_answer|
      json.partial! 'answer', app_answer: app_answer
    end
  end
end

