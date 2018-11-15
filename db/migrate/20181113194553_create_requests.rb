# frozen_string_literal: true

class CreateRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :requests do |t|
      t.string :operating_system
      t.integer :ram_mb
      t.integer :cpu_cores
      t.string :software
      t.text :comment
      t.text :rejection_information
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
