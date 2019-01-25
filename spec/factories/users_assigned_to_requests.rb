# frozen_string_literal: true

FactoryBot.define do
  factory :users_assigned_to_request do
    sudo { false }
    request_id { FactoryBot.create :request }
    user_id { FactoryBot.create :user }
  end
end
