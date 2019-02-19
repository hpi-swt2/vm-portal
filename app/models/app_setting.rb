# frozen_string_literal: true

class AppSetting < ApplicationRecord
  validates_inclusion_of :singleton_guard, in: [0]
  validates_format_of :github_user_email, with: Devise.email_regexp, allow_blank: true
  validates :email_notification_smtp_port, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 65_535 }, allow_nil: true
  validates :vm_archivation_timeout, numericality: { greater_than_or_equal_to: 0 }

  def self.instance
    first_or_create!(singleton_guard: 0,
                     github_user_email: 'email@example.com',
                     email_notification_smtp_port: 587,
                     vm_archivation_timeout: 3) # in days
  end
end
