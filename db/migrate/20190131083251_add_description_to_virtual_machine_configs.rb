class AddDescriptionToVirtualMachineConfigs < ActiveRecord::Migration[5.2]
  def change
    add_column :virtual_machine_configs, :description, :string
  end
end
