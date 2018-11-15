# frozen_string_literal: true

FactoryBot.define do
  factory :request do
    operating_system { 'MyString' }
    ram_mb { 1 }
    cpu_cores { 1 }
    software { 'MyString' }
    comment { 'Comment' }
    status { 'pending' }
  end
  factory :rejected_request, parent: :request do
    status { 'rejected' }
    rejection_information { 'Info' }
  end
end
