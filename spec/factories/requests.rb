# frozen_string_literal: true

FactoryBot.define do
  factory :request do
    name { 'MyVM' }
    cpu_cores { 2 }
    ram_mb { 1000 }
    storage_mb { 2000 }
    operating_system { 'MyOS' }
    description { 'Description' }
    comment { 'Comment' }
    status { 'pending' }
  end
  factory :rejected_request, parent: :request do
    status { 'rejected' }
    rejection_information { 'Info' }
  end

  factory :accepted_request, parent: :request do
    status { 'accepted' }
  end
end
