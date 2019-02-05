class AddPortForwardingToRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :requests, :port_forwarding, :boolean
  end
end
