# frozen_string_literal: true

class AddvSphereRootFolderToAppSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :app_settings, :vsphere_root_folder, :string, default: ''
  end
end
