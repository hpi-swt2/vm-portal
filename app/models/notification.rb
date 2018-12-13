# frozen_string_literal: true

class Notification < ApplicationRecord
  belongs_to :user
  default_scope { order(read: :asc, created_at: :desc) }
end
