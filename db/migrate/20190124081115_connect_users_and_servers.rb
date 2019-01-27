# frozen_string_literal: true

class ConnectUsersAndServers < ActiveRecord::Migration[5.2]
  def change
    remove_column :servers, :responsible, :string
    add_reference :servers, :responsible, references: :user, index: true
    add_foreign_key :servers, :users, column: :responsible_id
  end
end
