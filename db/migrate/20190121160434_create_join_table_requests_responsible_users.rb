class CreateJoinTableRequestsResponsibleUsers < ActiveRecord::Migration[5.2]
  def change
    create_join_table(:requests, :users, table_name: 'requests_responsible_users') do |t|
      t.index [:request_id, :user_id]
    end
  end
end
