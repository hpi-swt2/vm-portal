class CreateResponsibleUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :responsible_users do |t|
      t.integer :user_id, null: false
      t.integer :project_id, null: false
      t.index [:user_id, :project_id]
      t.index [:project_id, :user_id]
    end
  end
end
