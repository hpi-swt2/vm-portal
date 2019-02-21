# frozen_string_literal: true

class AppSetting < ApplicationRecord
  validates_inclusion_of :singleton_guard, in: [0]
  validates_format_of :github_user_email, with: Devise.email_regexp
  validates :github_user_name, :git_repository_name, :git_repository_url, presence: true
  validates :email_notification_smtp_port, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 65_535 }, allow_nil: true
  validates :vm_archivation_timeout, numericality: { greater_than_or_equal_to: 0 }

  after_commit :update_git, on: :update

  def update_git
    GitHelper.reset
  end

  def self.instance
    first_or_create!(singleton_guard: 0,
                     github_user_name: 'MyUserName',
                     github_user_email: 'example@email.com',
                     git_repository_name: 'repository',
                     git_repository_url: 'https://github.com/hpi-swt2/vm-portal.git',
                     vm_archivation_timeout: 3) # in days
  end
end
