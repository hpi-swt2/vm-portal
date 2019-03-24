# frozen_string_literal: true

FactoryBot.define do
  factory :notification do
    association :user, factory: :user
    title { 'Test Notification' }
    message { 'This is a test' }
    read { false }
    link { 'https://example.com' }
  end
end
