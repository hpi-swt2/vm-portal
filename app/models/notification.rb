# frozen_string_literal: true

class Notification < ApplicationRecord
  belongs_to :user
  enum notification_type: { default: 0, error: 1 }
  default_scope { order(read: :asc, created_at: :desc) }
end
