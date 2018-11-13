# frozen_string_literal: true

FactoryBot.define do
  factory :request do
    operating_system { 'MyString' }
    ram_mb { 1 }
    cpu_cores { 1 }
    software { 'MyString' }
    comment { 'MyString' }
    accepted { false }
  end
end
