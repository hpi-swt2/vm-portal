class CreateVirtualMachineConfigs < ActiveRecord::Migration[5.2]
  def change
    create_table :virtual_machine_configs do |t|
      t.string :name
      t.string :ip
      t.string :dns

      t.timestamps
    end
  end
end
