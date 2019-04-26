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

  after_commit :save_users
  after_initialize :assign_defaults

  attr_writer :sudo_users
  attr_writer :users

  def user_ids=(new_user_ids)
    @users = User.find(new_user_ids)
  end

  def sudo_user_ids=(new_sudo_users)
    @sudo_users = User.find(new_sudo_users)
  end

  # in this model, the groups: users, sudo_users, and responsible_users shall be seperate groups
  # They will be merged for writing puppet scripts and seperated when reading them

  def sudo_users
    read_users if @sudo_users.nil?

    @sudo_users
  end

  def users
    read_users if @users.nil?

    @users
  end

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
