class AddCountToNotifications < ActiveRecord::Migration[5.2]
  def change
    add_column :notifications, :count, :integer, default: 1
  end
end
