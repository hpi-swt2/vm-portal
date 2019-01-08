# frozen_string_literal: true

class RemoveSoftwareFromRequests < ActiveRecord::Migration[5.2]
  def change
    remove_column :requests, :software, :string
  end
end
