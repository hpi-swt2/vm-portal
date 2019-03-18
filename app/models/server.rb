# frozen_string_literal: true

# Part of Ruby stdlib, used for IP regexes
# https://www.rubydoc.info/stdlib/resolv/Resolv
require 'resolv'

class Server < ApplicationRecord
  belongs_to :responsible, class_name: :User
  validates :name, :cpu_cores, :ram_gb, :storage_gb, :mac_address, :fqdn, :responsible_id, presence: true
  validates :ipv4_address, presence: { unless: :ipv6_address? }
  validates :ipv6_address, presence: { unless: :ipv4_address? }
  serialize :installed_software, Array

  validates :cpu_cores, numericality: { greater_than: 0 }
  validates :ram_gb, numericality: { greater_than: 0 }
  validates :storage_gb, numericality: { greater_than: 0 }

  validates :ipv4_address, format: {
    with: Resolv::IPv4::Regex,
    message: 'is not a valid IPv4 address'
  }
  validates :ipv6_address, format: {
    with: Resolv::IPv6::Regex,
    message: 'is not a valid IPv6 address'
  }
  validates :mac_address, format: {
    with: /([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})/,
    message: 'is not a valid MAC address'
  }
end
