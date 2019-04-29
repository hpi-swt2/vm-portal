# frozen_string_literal: true

FactoryBot.define do
  factory :notification do
    association :user, factory: :user
    title { 'Test Notification' }
    message { 'This is a test' }
    read { false }
    link { 'https://example.com' }
  end

  factory :error_notification, parent: :notification do
    notification_type { :error }
    title { 'An Error occured!' }
  end

  factory :read_notification, parent: :notification do
    title { 'This notification is already read' }
    read { true }
  end
end
