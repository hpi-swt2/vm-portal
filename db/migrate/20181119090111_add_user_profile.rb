# frozen_string_literal: true

class AddUserProfile < ActiveRecord::Migration[5.2]
  def change
    create_table :user_profiles do |t|
      t.references :user
      t.string :first_name
      t.string :last_name
      t.timestamps
    end
  end
end
