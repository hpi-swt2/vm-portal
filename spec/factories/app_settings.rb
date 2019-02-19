FactoryBot.define do
  factory :app_setting do
    singleton_guard { 1 }
    git_repository_url { "MyString" }
    git_repository_name { "MyString" }
    github_user_name { "MyString" }
    github_user_email { "MyString" }
    vsphere_server_ip { "MyString" }
    vsphere_server_user { "MyString" }
    vsphere_server_password { "MyString" }
    email_notification_smtp_address { "MyString" }
    email_notification_smtp_port { 1 }
    email_notification_smtp_domain { "MyString" }
    email_notification_smtp_user { "MyString" }
    email_notification_smtp_password { "MyString" }
    vm_archivation_timeout { 1 }
  end
end
