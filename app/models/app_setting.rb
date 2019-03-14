# frozen_string_literal: true

require './app/api/v_sphere/folder'

class AppSetting < ApplicationRecord
  validates_inclusion_of :singleton_guard, in: [0]
  validates_format_of :github_user_email, with: Devise.email_regexp
  validates :github_user_name, :git_repository_name, :git_repository_url, presence: true
  validates :email_notification_smtp_port, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 65_535 }, allow_nil: true
  validates :vm_archivation_timeout, numericality: { greater_than_or_equal_to: 0 }
  validates :puppet_init_path, :puppet_nodes_path, :puppet_classes_path,
            format: { with: %r{\A\/?(?:[0-9a-zA-Z_-]+\/?)*\z}, message: 'has to be a valid UNIX file path' }
  validates :vsphere_root_folder,
            length: { maximum: VSphere::Folder::VSPHERE_FOLDER_NAME_CHARACTER_LIMIT },
            format: { without: %r{/%\/}, message: 'The vSphere root folder may not contain "/", "\" or "%"' }

  after_commit :apply_settings, on: :update

  def self.instance
    find(1)
  end

  private

  def apply_settings
    apply_mail_settings
    GitHelper.reset
  end

  def apply_mail_settings
    ActionMailer::Base.smtp_settings = {
      address: email_notification_smtp_address,
      port: email_notification_smtp_port,
      domain: email_notification_smtp_domain,
      user_name: email_notification_smtp_user,
      password: email_notification_smtp_password,
      authentication: :plain
    }
  end
end
