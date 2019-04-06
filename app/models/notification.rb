# frozen_string_literal: true

class Notification < ApplicationRecord
  belongs_to :user
  enum notification_type: { default: 0, error: 1 }
  default_scope { order(read: :asc, created_at: :desc) }

  def ==(other)
    # its fine to use instance_exec here because we know the other object is
    # also of our class and we want state to be private
    self.class == other.class &&
      state == other.instance_exec { state } &&
      (notification_date.to_f - other.notification_date.to_f).abs < 60 # seconds
    # we consider two notifications equal if they have the same contents and were created within one minute of each other
  end

  # necessary to approximate the creation date of new notifications which are not yet saved in the DB
  # For some reason we cannot call super.created_at, so use a different method name instead
  def notification_date
    creation_date = created_at
    creation_date.nil? ? DateTime.current : creation_date
  end

  private

  def state
    [title, message, read, user.id, link, notification_type]
  end
end
