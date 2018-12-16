# frozen_string_literal: true

class CreateRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :requests do |t|
      t.string :name
      t.integer :cpu_cores
      t.integer :ram_mb
      t.integer :storage_mb
      t.string :operating_system
      t.string :software
      t.integer :port
      t.string :application_name
      t.text :comment
      t.text :rejection_information
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
