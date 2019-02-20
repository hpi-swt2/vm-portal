# frozen_string_literal: true

json.extract! app_setting, :id, :singleton_guard, :git_repository_url, :git_repository_name, :github_user_name, :github_user_email, :vsphere_server_ip, :vsphere_server_user, :vsphere_server_password, :email_notification_smtp_address, :email_notification_smtp_port, :email_notification_smtp_domain, :email_notification_smtp_user, :email_notification_smtp_password, :vm_archivation_timeout, :created_at, :updated_at
json.url app_setting_url(app_setting, format: :json)
