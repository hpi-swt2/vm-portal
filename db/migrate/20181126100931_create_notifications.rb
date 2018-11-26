# frozen_string_literal: true

class CreateNotifications < ActiveRecord::Migration[5.2]
  def change
    create_table :notifications do |t|
      t.references :user, foreign_key: true
      t.string :title
      t.string :message
      t.boolean :read

      t.timestamps
    end
  end
end
