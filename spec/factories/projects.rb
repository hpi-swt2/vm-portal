# frozen_string_literal: true

FactoryBot.define do
  factory :project do
    name { 'MyProject' }
    description { 'Useful Description' }
    responsible_users { [FactoryBot.create(:employee)] }
  end
end
