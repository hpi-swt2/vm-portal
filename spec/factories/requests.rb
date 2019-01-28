# frozen_string_literal: true

FactoryBot.define do
  factory :request do
    name { Faker::Name.first_name }
    cpu_cores { Faker::Number.between(1, 10) }
    ram_mb { Faker::Number.between(1, 10) }
    storage_mb { Faker::Number.between(1, 10) }
    operating_system { 'MyOS' }
    description { Faker::HarryPotter.quote }
    comment { Faker::Hobbit.quote }
    status { 'pending' }
    user { FactoryBot.create :admin }
  end

  factory :rejected_request, parent: :request do
    status { 'rejected' }
    rejection_information { Faker::FamousLastWords.last_words }
  end

  factory :accepted_request, parent: :request do
    status { 'accepted' }
  end

  factory :request_with_users, parent: :request do
    transient do
      users_count { 4 }
    end

    after(:create) do |request, evaluator|
      create_list(:user, evaluator.users_count, requests: [request])
    end
  end
end
