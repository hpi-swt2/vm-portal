# frozen_string_literal: true

class RenameRequestMbToGb < ActiveRecord::Migration[5.2]
  def up
    rename_column :requests, :ram_mb, :ram_gb
    rename_column :requests, :storage_mb, :storage_gb
    update_requests
  end

  def update_requests
    Request.all.each do |request|
      unless request.nil?
        request.ram_gb = (request.ram_gb / 1000.0).ceil
        request.storage_gb = (request.storage_gb / 1000.0).ceil
      end
      request.save
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
