# frozen_string_literal: true

class RenameServerMbToGb < ActiveRecord::Migration[5.2]
  def change
    rename_column :servers, :ram_mb, :ram_gb
    rename_column :servers, :storage_mb, :storage_gb
    add_column :servers, :model, :string
    add_column :servers, :vendor, :string
    add_column :servers, :description, :string
  end
end
