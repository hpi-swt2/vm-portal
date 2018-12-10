# frozen_string_literal: true

class CreateUsersAssignedToRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :users_assigned_to_requests do |t|
      t.boolean 'sudo'
      t.integer 'request_id'
      t.integer 'user_id'
      t.datetime 'created_at', null: false
      t.datetime 'updated_at', null: false
      t.index ['request_id'], name: 'index_users_assigned_to_requests_on_request_id'
      t.index ['user_id'], name: 'index_users_assigned_to_requests_on_user_id'
      t.timestamps
    end
  end
end
