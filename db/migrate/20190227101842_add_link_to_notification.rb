class AddLinkToNotification < ActiveRecord::Migration[5.2]
  def change
    change_table :notifications do |t|
      t.string :link
    end
  end
end
