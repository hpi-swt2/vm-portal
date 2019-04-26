# frozen_string_literal: true

class Notification < ApplicationRecord
  belongs_to :user
  enum notification_type: { default: 0, error: 1 }
  default_scope { order(read: :asc, created_at: :desc) }

  def duplicate_of(other)
    # its fine to use instance_exec here because we know the other object is
    # also of our class and we want state to be private
    self.class == other.class &&
      state == other.instance_exec { state } &&
      (created_at.to_f - other.created_at.to_f).abs < 60 # seconds
    # we consider two notifications to be a duplicate of each other if they have the same contents and were created within one minute of each other
  end

  private

  def state
    [title, message, read, user.id, link, notification_type]
  end
end
