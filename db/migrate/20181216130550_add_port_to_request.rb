class AddPortToRequest < ActiveRecord::Migration[5.2]
  def change
    add_column :requests, :port, :integer
  end
end
