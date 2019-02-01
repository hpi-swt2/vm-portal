# frozen_string_literal: true

class VirtualMachineConfig < ApplicationRecord
  has_and_belongs_to_many :responsible_users, class_name: 'User'
end
