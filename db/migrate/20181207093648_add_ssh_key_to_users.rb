class AddSshKeyToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :sshkey, :string
  end
end
