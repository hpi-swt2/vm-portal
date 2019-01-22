# frozen_string_literal: true

FactoryBot.define do
  factory :server do
    name { 'MyString' }
    cpu_cores { 1 }
    ram_gb { 1 }
    storage_gb { 1 }
    mac_address { 'C0:FF:EE:00:00:42' }
    fqdn { 'arrr.speck.de' }
    ipv4_address { '8.8.8.8' }
    ipv6_address { '::1' }
    installed_software { ['some software'] }
    responsible { 'Hans Wurst' }
  end
end
