# frozen_string_literal: true

FactoryBot.define do
  factory :request do
    name { Faker::Alphanumeric.unique.alphanumeric 10 }
    cpu_cores { 2 }
    ram_gb { 1 }
    storage_gb { 3 }
    operating_system { 'MyOS' }
    description { 'Description' }
    comment { 'Comment' }
    status { 'pending' }
    user { FactoryBot.create :admin }
    responsible_users { [FactoryBot.create(:user)] }
    project { FactoryBot.create(:project) }
    port_forwarding { true }
    port { 4000 }
    application_name { 'MyName' }
  end

  factory :rejected_request, parent: :request do
    status { 'rejected' }
    rejection_information { 'Info' }
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
