class CreateAppSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :app_settings do |t|
      t.integer :singleton_guard
      t.string :git_repository_url
      t.string :git_repository_name
      t.string :github_user_name
      t.string :github_user_email
      t.string :vsphere_server_ip
      t.string :vsphere_server_user
      t.string :vsphere_server_password
      t.string :email_notification_smtp_address
      t.integer :email_notification_smtp_port
      t.string :email_notification_smtp_domain
      t.string :email_notification_smtp_user
      t.string :email_notification_smtp_password
      t.integer :vm_archivation_timeout

      t.timestamps
    end
    # Ensure that we only have one setting entry
    add_index :app_settings, :singleton_guard, unique: true
  end
end
