# frozen_string_literal: true

class AddApplicationNameToRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :requests, :application_name, :string
  end
end
