class CreateRequestTemplates < ActiveRecord::Migration[5.2]
  def change
    create_table :request_templates do |t|
      t.integer :cpu_count
      t.integer :ram_mb
      t.integer :storage_mb
      t.string :operating_system

      t.timestamps
    end
  end
end
