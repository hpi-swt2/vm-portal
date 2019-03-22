# frozen_string_literal: true

FactoryBot.define do
  factory :app_setting do
    singleton_guard { 1 }
    vsphere_server_ip { '127.0.0.1' }
    vsphere_server_user { 'user@domain.tld' }
    vsphere_server_password { 'verySecure' }
    vsphere_root_folder { '/' }
    min_cpu_cores { 1 }
    max_cpu_cores { 64 }
    max_ram_size { 128 }
    max_storage_size { 1024 }
    git_repository_url { 'git@github.com-userName:userName/repoName.git' }
    git_repository_name { 'repoName' }
    git_branch { 'master' }
    github_user_name { 'userName' }
    github_user_email { 'user@domain.tld' }
    puppet_init_path { '/' }
    puppet_classes_path { '/Name' }
    puppet_nodes_path { '/Node' }
    email_notification_smtp_address { 'smtp.provider.com' }
    email_notification_smtp_port { 587 }
    email_notification_smtp_domain { 'provider.com' }
    email_notification_smtp_user { 'hart@provider.com' }
    email_notification_smtp_password { 'verySecureToo' }
    vm_archivation_timeout { 3 }
    max_shown_vms { 10 }
  end
end
