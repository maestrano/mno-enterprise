json.partial! 'app_review', app_review: app_answer, show_rating: false
json.question_id app_answer[:parent_id]
