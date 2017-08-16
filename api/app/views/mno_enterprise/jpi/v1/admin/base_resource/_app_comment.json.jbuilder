json.partial! 'app_review', app_review: app_comment, show_rating: false
json.feedback_id app_comment[:parent_id]
