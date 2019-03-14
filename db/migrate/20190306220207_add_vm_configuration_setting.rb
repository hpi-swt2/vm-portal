# frozen_string_literal: true

class AddVmConfigurationSetting < ActiveRecord::Migration[5.2]
  def change
    add_column :app_settings, :min_cpu_cores, :integer
    add_column :app_settings, :max_cpu_cores, :integer
    add_column :app_settings, :max_ram_size, :integer
    add_column :app_settings, :max_storage_size, :integer
  end
end
