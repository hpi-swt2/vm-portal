class CreateServers < ActiveRecord::Migration[5.2]
  def change
    create_table :servers do |t|
      t.string :name
      t.integer :cpu_cores
      t.integer :ram_mb
      t.integer :storage_mb
      t.string :mac_address
      t.string :fqdn
      t.string :ipv4_address
      t.string :ipv6_address
      t.string :installed_software, default: [].to_yaml

      t.timestamps
    end
  end
end
