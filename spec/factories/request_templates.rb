# frozen_string_literal: true

FactoryBot.define do
  factory :request_template do
    cpu_count { 1 }
    ram_mb { 1 }
    storage_mb { 1 }
    operating_system { 'MyString' }
  end
end
