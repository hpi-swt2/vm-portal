# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: %i[hpi]
   :trackable
  enum role: %i[user wimi admin]

  has_many :users_assigned_to_requests
  has_many :requests, through: :users_assigned_to_requests
  has_one :user_profile
  accepts_nested_attributes_for :user_profile
  validates :first_name, presence: true
  validates :last_name, presence: true

  # slack integration
  has_many :slack_auth_requests, dependent: :destroy
  has_many :slack_hooks, dependent: :destroy
  def notify_slack(message)
    slack_hooks.each do |hook|
      hook.post_message message
    end
  end

  after_initialize :set_default_role, if: :new_record?

  def name
    "#{first_name} #{last_name}"
  end

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]

      profile = UserProfile.find_or_create_by(user: user)
      profile.first_name = auth.info.first_name
      profile.last_name = auth.info.last_name
      profile.save
    end

  end

  private

  def set_default_role
    self.role ||= :user
  end
end
