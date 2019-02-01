# frozen_string_literal: true

class CreateJoinTableVirtualMachineConfigUsers < ActiveRecord::Migration[5.2]
  def change
    create_join_table :virtual_machine_configs, :users do |t|
      t.index %i[virtual_machine_config_id user_id], name: 'index_virtual_machine_configs_responsible_users'
      t.index %i[user_id virtual_machine_config_id], name: 'index_responsible_users_virtual_machine_configs'
    end
  end
end
