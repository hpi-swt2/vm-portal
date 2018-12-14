# frozen_string_literal: true

require 'faker'
require 'sshkey'

FactoryBot.define do
  factory :user do
    # https://github.com/stympy/faker/blob/master/doc/v1.9.1/internet.md#fakerinternet
    email { Faker::Internet.safe_email }
    password { Faker::Internet.password(min_length = 10, max_length = 20, mix_case = true, special_chars = true) }
    password_confirmation { password }
    first_name { 'Max' }
    last_name { 'Mustermann' }
    ssh_key { SSHKey.generate.public_key }
  end
end
