# frozen_string_literal: true

class CreateResponsibleUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :responsible_users do |t|
      t.integer :user_id, null: false
      t.integer :project_id, null: false
      t.index %i[user_id project_id]
      t.index %i[project_id user_id]
    end
  end
end
