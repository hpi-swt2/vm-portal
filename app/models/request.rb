# frozen_string_literal: true

class Request < ApplicationRecord
  has_many :users_assigned_to_requests
  has_many :users, through: :users_assigned_to_requests

  attr_accessor :sudo_user_ids

  enum status: %i[pending accepted rejected]
  validates :name, :cpu_cores, :ram_mb, :storage_mb, :operating_system, presence: true
  validates :cpu_cores, numericality: { greater_than: 0, less_than: 65 }
  validates :ram_mb, numericality: { greater_than: 0, less_than: 257_000 }
  validates :storage_mb, numericality: { greater_than: 0, less_than: 1_000_000 }
end
