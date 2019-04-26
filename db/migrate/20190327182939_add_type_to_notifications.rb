# frozen_string_literal: true

class AddTypeToNotifications < ActiveRecord::Migration[5.2]
  def change
    add_column :notifications, :notification_type, :integer, default: 0
  end
end
