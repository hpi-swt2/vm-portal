class CreateArchivationRequest < ActiveRecord::Migration[5.2]
  def change
    create_table :archivation_requests do |t|
      t.string :name, null: false

      t.timestamps
    end
  end
end
