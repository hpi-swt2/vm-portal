class AddDescriptionToRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :requests, :description, :text
  end
end
