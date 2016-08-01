FactoryGirl.define do
  factory :task do
    sequence(:name) { |n| Faker::Name.title }
    sequence(:description) { |n| Faker::Lorem.paragraph(2, true) }

    state 'new'

    user
  end
end

