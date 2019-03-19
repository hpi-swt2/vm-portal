class AddMaxShownVms < ActiveRecord::Migration[5.2]
  def change
    add_column :app_settings, :max_shown_vms, :integer, default: 10
  end
end
