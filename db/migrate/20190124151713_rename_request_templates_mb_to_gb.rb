# frozen_string_literal: true

class RenameRequestTemplatesMbToGb < ActiveRecord::Migration[5.2]
  def change
    rename_column :request_templates, :ram_mb, :ram_gb
    rename_column :request_templates, :storage_mb, :storage_gb
  end
end
