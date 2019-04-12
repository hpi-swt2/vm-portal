# frozen_string_literal: true

class Project < ApplicationRecord
  has_and_belongs_to_many :responsible_users,
                          class_name: 'User',
                          join_table: :responsible_users,
                          foreign_key: :user_id,
                          association_foreign_key: :project_id
  has_many :virtual_machine_configs

  validates :name, presence: true
  validates :description, presence: true
  validates :responsible_users, presence: true
end
