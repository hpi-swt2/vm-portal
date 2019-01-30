# frozen_string_literal: true

require 'sshkey'
require 'vmapi.rb'

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable

  after_create :set_user_id, :update_repository
  after_initialize :set_default_role, if: :new_record?

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable, :omniauthable, omniauth_providers: %i[hpi]
  enum role: %i[user employee admin]

  has_many :users_assigned_to_requests
  has_many :requests, through: :users_assigned_to_requests
  has_many :servers
  validates :first_name, presence: true
  validates :last_name, presence: true
  validate :valid_ssh_key

  has_and_belongs_to_many :responsible_projects,
                          class_name: 'Project',
                          join_table: :responsible_users,
                          foreign_key: :project_id,
                          association_foreign_key: :user_id

  # slack integration
  has_many :slack_auth_requests, dependent: :destroy
  has_many :slack_hooks, dependent: :destroy
  def notify_slack(message)
    slack_hooks.each do |hook|
      hook.post_message message
    end
  end

  # notifications
  def notify(title, message)
    notify_slack("*#{title}*\n#{message}")

    if self.email_notifications
      NotificationMailer.with(user: self, title: "#{title}", message: "#{message}").notify_email.deliver_now
    end

    notification = Notification.new title: title, message: message
    notification.user_id = id
    notification.read = false
    notification.save # saving might fail, but there is no useful way to handle the error.
  end

  after_initialize :set_default_role, if: :new_record?

  def ssh_key?
    ssh_key&.length&.positive?
  end

  def name
    "#{first_name} #{last_name}"
  end

  def valid_ssh_key
    errors.add(:danger, 'Invalid SSH-Key') unless valid_ssh_key?
  end

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.role = :user

      user.first_name = auth.info.first_name
      user.last_name = auth.info.last_name
    end
  end

  def vms
    VSphere::VirtualMachine.user_vms self
  end

  def employee_or_admin?
    employee? || admin?
  end

  private

  def set_default_role
    self.role ||= :user
  end

  def set_user_id
    # Lock this method to prevent race conditions when two users are created at the same time
    User.with_advisory_lock('user_id_lock') do
      self.user_id = if User.maximum(:user_id)
                       (User.maximum(:user_id) + 1) || Rails.configuration.start_user_id
                     else
                       Rails.configuration.start_user_id
                     end
      save
    end
  end

  def update_repository
    path = File.join Rails.root, 'public', 'puppet_script_temp'

    begin
      GitHelper.write_to_repository(path) do |git_writer|
        git_writer.write_file('init.pp', generate_puppet_init_script)
        message = if git_writer.added?
                    'Create init.pp'
                  else
                    "Add #{name}"
                  end
        git_writer.save(message)
      end
    end
  end

  def generate_puppet_init_script
    Puppetscript.init_scrit(User.all)
  end

  def valid_ssh_key?
    !ssh_key? || SSHKey.valid_ssh_public_key?(ssh_key)
  end
end
