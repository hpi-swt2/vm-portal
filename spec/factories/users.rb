# frozen_string_literal: true

require 'faker'
require 'sshkey'

FactoryBot.define do
  factory :user do
    # https://github.com/stympy/faker/blob/master/doc/v1.9.1/internet.md#fakerinternet
    email { Faker::Internet.safe_email }
    password { Faker::Internet.password(10, 20, true, true) }
    password_confirmation { password }
    first_name { 'Max' }
    last_name { 'Mustermann' }
    ssh_key { SSHKey.generate.ssh_public_key }
  end

  factory :admin, parent: :user do
    role { :admin }
  end

  factory :employee, parent: :user do
    role { :employee }
  end
end
