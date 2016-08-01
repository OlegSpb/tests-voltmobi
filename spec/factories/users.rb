FactoryGirl.define do

  factory :user do
    sequence(:email) { |n| Faker::Internet.email }

    role 'user'
    password { email}

    factory :user_with_tasks do
      transient do
        tasks_count 5
      end

      after(:create) do |user, evaluator|
        create_list(:task, evaluator.tasks_count, user: user)
      end
    end
  end

  factory :admin, class: User do
    sequence(:email) { |n| Faker::Internet.email }

    role 'admin'
    password { email}
  end
end
