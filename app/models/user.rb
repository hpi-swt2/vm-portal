# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :users_assigned_to_requests
  has_many :requests, through: :users_assigned_to_requests
  has_one :user_profile
  accepts_nested_attributes_for :user_profile
end
