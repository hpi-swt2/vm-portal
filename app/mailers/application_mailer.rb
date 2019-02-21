# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'noreply@vm-portal.com'
  layout 'mailer'

  before_filter :set_mailer_settings

  private

  def set_mailer_settings
    setting = AppSetting.instance
    ActionMailer::Base.smtp_settings = {
      address: setting.email_notification_smtp_address,
      port: setting.email_notification_smtp_port,
      domain: setting.email_notification_smtp_domain,
      user_name: setting.email_notification_smtp_user,
      password: setting.email_notification_smtp_password,
      authentication: :plain
    }
  end
end
