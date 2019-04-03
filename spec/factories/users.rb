# frozen_string_literal: true

require 'faker'

FactoryBot.define do
  factory :user do
    # https://github.com/stympy/faker/blob/master/doc/v1.9.1/internet.md#fakerinternet
    email { Faker::Internet.unique.safe_email }
    password { Faker::Internet.password(10, 20, true, true) }
    password_confirmation { password }
    first_name { 'Max' }
    last_name { 'Mustermann' }
    # Dynamically generating SSH keys using the 'SSHKey' library is expensive
    ssh_key { 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDBBzYYubPSfjc6Q1zcZpzijq40QnPrjgOoXyNrzohREX0GOXe73g6/e4Atk/Y+MMOBO0tSOPrVHZT0BpPgtWvamJCjGW0+HmcSoa4XN/bsf2lsVtrDiUk4T+OxpipCIQEp+vizl+xscwTz4FCK5vFU+I97QFnzKrUmqqG4i2OEZ/Y8P3f7jedcRD9AZttU89WvOpmAm4DnFE1MvRr2gjyIIfuBBGI+tmIO4a+pZE8/xZlLuIFWQohUGtGCluhsn6QlYqy05dyqZNFlFfut7OxkgJmRxezIR42UgZcshh5LdiX7Vz5AsMlnJclr+lDWimTULYjF8FarVFJgchWoXFf9' }
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
