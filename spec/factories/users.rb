# frozen_string_literal: true

require 'faker'
require 'sshkey'

FactoryBot.define do
  factory :user do
    # https://github.com/stympy/faker/blob/master/doc/v1.9.1/internet.md#fakerinternet
    email { Faker::Internet.unique.safe_email }
    password { Faker::Internet.password(10, 20, true, true) }
    password_confirmation { password }
    first_name { 'Max' }
    last_name { 'Mustermann' }
    ssh_key { SSHKey.generate.ssh_public_key }
    responsible_projects { [] }
  end

  factory :admin, parent: :user do
    role { :admin }
  end

  factory :employee, parent: :user do
    role { :employee }
  end

  factory :puppet_admin, parent: :admin do
    first_name { 'Vorname' }
    last_name { 'Nachname' }
    email { 'vorname.nachname@hpi.de' }
  end

  factory :puppet_admin2, parent: :admin do
    first_name { 'weitererVorname' }
    last_name { 'Nachname' }
    email { 'weitererVorname.nachname@hpi.de' }
  end

  factory :puppet_user, parent: :user do
    first_name { 'andererVorname' }
    last_name { 'Nachname' }
    email { 'andererVorname.nachname@hpi.de' }
  end

  factory :puppet_user2, parent: :user do
    first_name { 'andererVorname' }
    last_name { 'Nachname' }
    email { 'andererVorname2.nachname@hpi.de' }
  end
end
