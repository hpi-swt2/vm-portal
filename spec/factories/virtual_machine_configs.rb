# frozen_string_literal: true

FactoryBot.define do
  factory :virtual_machine_config do
    name { 'My VM' }
    ip { '127.0.0.1' }
    dns { 'my-vm.epic-hpi.de' }
    responsible_users { [FactoryBot.create(:user)] }
  end
end
