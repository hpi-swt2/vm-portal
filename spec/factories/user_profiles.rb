# frozen_string_literal: true

FactoryBot.define do
  factory :user_profile do
    first_name { 'Max' }
    last_name { 'Mustermann' }
  end
end
