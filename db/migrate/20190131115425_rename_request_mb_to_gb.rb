# frozen_string_literal: true

class RenameRequestMbToGb < ActiveRecord::Migration[5.2]
  def up
    update_requests
    rename_column :requests, :ram_mb, :ram_gb
    rename_column :requests, :storage_mb, :storage_gb
  end

  def update_requests
    Request.all.each do |request|
      unless request.nil?
        request.ram_mb = request.ram_mb / 1000
        request.storage_mb = request.storage_mb / 1000
      end
      request.save
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
