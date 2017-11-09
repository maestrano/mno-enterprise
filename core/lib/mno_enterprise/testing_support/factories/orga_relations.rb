# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :mno_enterprise_orga_relation, :class => 'MnoEnterprise::OrgaRelation' do

    factory :orga_relation, class: MnoEnterprise::OrgaRelation do
      sequence(:id)
      user { build(:user).attributes }
      organization { build(:organization).attributes }
      role 'admin'
      # Properly build the resource with Her
      initialize_with { new(attributes).tap { |e| e.clear_attribute_changes! } }
    end
  end
end
