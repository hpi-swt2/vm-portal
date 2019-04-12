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

  MAX_NAME_LENGTH = 20
  validates :name,
            length: { maximum: MAX_NAME_LENGTH, message: 'only allows a maximum of %{count} characters' },
            format: { with: /\A[a-z0-9\-]+\z/, message: 'only allows lowercase letters, numbers and "-"' }
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

  def all_users
    (users + sudo_users + responsible_users).uniq
  end

  # This makes a few things easier, for example when adding arrays together
  def responsible_users
    responsible.nil? ? [] : [responsible]
  end

  def assign_defaults
    self.name = '' if name.nil?
  end

  private

  def read_users
    begin
      GitHelper.open_git_repository do
        remote_users = Puppetscript.read_node_file name
        @users = remote_users[:users] || [] if @users.nil?
        @sudo_users = remote_users[:admins] || [] if @sudo_users.nil?
      end
    rescue Git::GitExecuteError, RuntimeError => e
      Rails.logger.error(e)
      # ensure users and sudo_users are always valid arrays
      @users = [] if @users.nil?
      @sudo_users = [] if @sudo_users.nil?
    end
    @users -= @sudo_users
    @sudo_users -= responsible_users
  end

  def convert_to_user(user_or_id)
    user.is_a? User ? user : User.find(user_or_id)
  end

  def commit_message(git_writer)
    if git_writer.added?
      'Add ' + name
    elsif git_writer.updated?
      'Update ' + name
    else
      ''
    end
  end

  def node_script
    Puppetscript.node_script(name, (sudo_users + responsible_users).uniq, all_users)
  end

  def write_puppetscripts(git_writer, name_script, node_script)
    git_writer.write_file(Puppetscript.class_file_name(name), name_script)
    git_writer.write_file(Puppetscript.node_file_name(name), node_script)
    message = commit_message(git_writer)
    git_writer.save(message)
  end

  def _save_users
    GitHelper.open_git_repository for_write: true do |git_writer|
      name_script = Puppetscript.name_script name
      write_puppetscripts git_writer, name_script, node_script
    end
  rescue Git::GitExecuteError, RuntimeError => e
    Rails.logger.error(e)
    # update local user assignments again to reflect the written status (if available)
    @users = @sudo_users = nil
    read_users
  end

  def save_users
    _save_users if @users || @sudo_users
  end
end
