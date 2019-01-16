# frozen_string_literal: true

class CreateUsersAssignedToRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :users_assigned_to_requests do |t|
      t.boolean 'sudo'
      t.integer 'request_id'
      t.integer 'user_id'
      t.datetime 'created_at', null: false
      t.datetime 'updated_at', null: false
      t.timestamps
    end
  end
end
