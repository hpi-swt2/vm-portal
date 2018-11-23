FactoryBot.define do
  factory :vm do
    name { "My new VM" }
    cpu { "2" }
    ram { "1024" }
    capacity { "10" }
  end
end