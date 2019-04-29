# frozen_string_literal: true

# Part of Ruby stdlib, used for IP regexes
# https://www.rubydoc.info/stdlib/resolv/Resolv
require 'resolv'

class Server < Machine
  belongs_to :responsible, class_name: :User

  validates :name, :cpu_cores, :ram_gb, :storage_gb, :mac_address, :fqdn, :responsible_id, presence: true
  validates :ipv4_address, presence: { unless: :ipv6_address? }
  validates :ipv6_address, presence: { unless: :ipv4_address? }
  serialize :installed_software, Array

  validates :cpu_cores, numericality: { greater_than: 0 }
  validates :ram_gb, numericality: { greater_than: 0 }
  validates :storage_gb, numericality: { greater_than: 0 }

  validates :name,
            uniqueness: true,
            length: { minimum: 1 },
            format: { with: /\A[a-zA-Z0-9\-]+\z/, message: 'only allows letters, numbers and "-"' }
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

  # ActiveRecord defaults can't be used here, as the instance might not be saved
  after_initialize :assign_defaults

  # There is actually only ever one responsible user
  # This method is a convenience accessor to allow for easier array concatination
  # It is also recommended to use this method instead of :responsible because we might want to allow multiple responsible users in the future.
  def responsible_users
    responsible.nil? ? [] : [responsible]
  end

  def assign_defaults
    self.name = '' if name.nil?
  end
end
