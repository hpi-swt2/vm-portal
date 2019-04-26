# frozen_string_literal: true

require './lib/puppetscript'
require './lib/git_helper'

class VirtualMachineConfig < Machine
  has_and_belongs_to_many :responsible_users, class_name: 'User'
  belongs_to :project, optional: true

  after_commit :save_users

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
  
  def node_script
    Puppetscript.node_script(name, (sudo_users + responsible_users).uniq, all_users)
  end

  private

  def convert_to_user(user_or_id)
    user.is_a? User ? user : User.find(user_or_id)
  end
end
