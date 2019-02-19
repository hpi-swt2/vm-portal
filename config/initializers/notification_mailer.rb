# frozen_string_literal: true

Rails.configuration.action_mailer.smtp_settings = {
  address: AppSetting.instance.email_notification_smtp_address,
  port: AppSetting.instance.email_notification_smtp_port,
  domain: AppSetting.instance.email_notification_smtp_domain,
  user_name: AppSetting.instance.email_notification_smtp_user,
  password: AppSetting.instance.email_notification_smtp_password,
  authentication: :plain
}
