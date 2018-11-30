# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :slack_auth_requests, dependent: :destroy
  has_many :slack_hooks, dependent: :destroy

  def notify_slack(message)
    slack_hooks.each do |hook|
      hook.post_message message
    end
  end
end
