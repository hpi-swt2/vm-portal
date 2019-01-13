# frozen_string_literal: true

class Project < ApplicationRecord
  has_and_belongs_to_many :responsible_users,
                          class_name: 'User',
                          join_table: :responsible_users,
                          foreign_key: :user_id,
                          association_foreign_key: :project_id

  validates :name, presence: true
  validates :description, presence: true

  validate :validate_responsible_users

  def validate_responsible_users
    return if responsible_users.empty?

    errors.add :responsible_users, 'Each project needs at least one responsible user'
  end
end
