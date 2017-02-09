# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :mno_enterprise_app_review, :class => 'AppReview' do

    factory :app_review, class: MnoEnterprise::AppReview do
      sequence(:id)
      description 'Some Description'
      status 'approved'
      rating 3
      app_id 'app-id'
      app_name 'the app'
      user_id 'usr-11'
      user_name 'Jean Bon'
      organization_id 'org-11'
      organization_name 'Organization 11'
      created_at 3.days.ago
      updated_at 1.hour.ago
      edited true
      edited_by_name 'Jane Dale'
      edited_by_admin_role 'admin'
      edited_by_id 1

      user_admin_role 'admin'
      # Properly build the resource with Her
      initialize_with { new(attributes).tap { |e| e.clear_attribute_changes! } }

      factory :app_feedback, class: MnoEnterprise::AppFeedback do
        type 'Feedback'
        sequence(:description) { |n| "Feedback ##{n}" }
      end

      factory :app_question, class: MnoEnterprise::AppQuestion do
        type 'Question'
        sequence(:description) { |n| "Question ##{n}" }
      end

      factory :app_comment, class: MnoEnterprise::AppComment do
        type 'Comment'
        sequence(:description) { |n| "Comment ##{n}" }
        feedback_id 'feedback-id'
      end

      factory :app_answer, class: MnoEnterprise::AppAnswer do
        type 'Answer'
        sequence(:description) { |n| "Answer ##{n}" }
        question_id 'question-id'
      end
    end
  end
end
