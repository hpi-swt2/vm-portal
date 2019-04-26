# frozen_string_literal: true

require './lib/puppetscript'
require './lib/git_helper'

class VirtualMachineConfig < Machine
  has_and_belongs_to_many :responsible_users, class_name: 'User'
  belongs_to :project, optional: true

  after_commit :save_users

  attr_writer :sudo_users
  attr_writer :users
end
