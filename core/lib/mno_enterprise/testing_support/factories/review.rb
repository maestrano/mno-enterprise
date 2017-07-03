# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :mno_enterprise_app_review, :class => 'AppReview' do

    factory :review, class: MnoEnterprise::Review do
      sequence(:id)
      description 'Some Description'
      status 'approved'
      rating 3
      app_id 'app-id'
      reviewable_id 'app-id'
      reviewable_type 'App'
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
      review_type 'Review'
      versions nil

      factory :feedback, class: MnoEnterprise::Feedback do
        review_type 'Feedback'
        sequence(:description) { |n| "Feedback ##{n}" }
      end

      factory :question, class: MnoEnterprise::Question do
        review_type 'Question'
        sequence(:description) { |n| "Question ##{n}" }
      end

      factory :comment, class: MnoEnterprise::Comment do
        review_type 'Comment'
        sequence(:description) { |n| "Comment ##{n}" }
        parent_id 'feedback-id'
      end

      factory :answer, class: MnoEnterprise::Answer do
        review_type 'Answer'
        sequence(:description) { |n| "Answer ##{n}" }
        parent_id 'question-id'
      end
    end
  end
end
