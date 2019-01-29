# frozen_string_literal: true

FactoryBot.define do
  factory :request_template do
    name { 'My Template' }
    cpu_cores { 1 }
    ram_gb { 1 }
    storage_gb { 1 }
    operating_system { 'MyString' }
  end
end
