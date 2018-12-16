# frozen_string_literal: true

class RenameSshKeyField < ActiveRecord::Migration[5.2]
  def change
    rename_column :users, :sshkey, :ssh_key
  end
end
