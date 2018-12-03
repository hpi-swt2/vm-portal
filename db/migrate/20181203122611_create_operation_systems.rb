# frozen_string_literal: true

class CreateOperationSystems < ActiveRecord::Migration[5.2]
  def change
    create_table :operation_systems do |t|
      t.string :name

      t.timestamps
    end
  end
end
