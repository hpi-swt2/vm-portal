class CreateSlackAuthRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :slack_auth_requests do |t|
      t.string :state
      t.belongs_to :user, index: true

      t.timestamps
    end
  end
end
