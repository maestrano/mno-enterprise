FactoryGirl.define do
  factory :asset, class: MnoEnterprise::Asset do
    transient do
      product nil
    end
    sequence(:id, &:to_s)
    sequence(:url) { |e| "http://localhost:3000/#{e}"}
    field_name 'screenshots'
  end
end
