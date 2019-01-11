FactoryBot.define do
  factory :server1 do
    name { "MyString" }
    cpu_cores { 1 }
    ram_mb { 1 }
    storage_mb { 1 }
    mac_address { "C0:FF:EE:00:00:42" }
    fqdn { "arrr.speck.de" }
    ipv4_address { "8.8.8.8" }
    ipv6_address { "::1" }
    installed_software { ["some software"] }
  end

  factory :server2 do
    name { "MyString" }
    cpu_cores { 1 }
    ram_mb { 1 }
    storage_mb { 1 }
    mac_address { "C0:FF:EE:00:00:42" }
    fqdn { "arrr.speck.de" }
    ipv4_address { "" }
    ipv6_address { "::1" }
    installed_software { ["some software"] }
  end

  factory :server3 do
    name { "MyString" }
    cpu_cores { 1 }
    ram_mb { 1 }
    storage_mb { 1 }
    mac_address { "C0:FF:EE:00:00:42" }
    fqdn { "arrr.speck.de" }
    ipv4_address { "8.8.8.8" }
    installed_software { ["some software"] }
  end
end
