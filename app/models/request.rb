# frozen_string_literal: true

class Request < ApplicationRecord
  has_many :users_assigned_to_requests
  has_many :users, through: :users_assigned_to_requests

  attr_accessor :sudo_user_ids

  enum status: %i[pending accepted rejected]
  validates :name, :cpu_cores, :ram_mb, :storage_mb, :operating_system, :description, presence: true
  validates :cpu_cores, numericality: { greater_than: 0, less_than: 65 }
  validates :ram_mb, numericality: { greater_than: 0, less_than: 257_000 }
  validates :storage_mb, numericality: { greater_than: 0, less_than: 1_000_000 }

  def description_text
    description = "- Name: #{name}\n"
    description += "- CPU cores: #{cpu_cores}\n"
    description += "- RAM: #{ram_mb} MB\n"
    description += "- Storage: #{storage_mb} MB\n"
    description += "- Operating System: #{operating_system}"
    description += comment.empty? ? '' : "\n- Comment: #{comment}"
    description
  end

  def accept!
    self.status = 'accepted'
  end

  def assign_sudo_users(sudo_user_ids)
    unless sudo_user_ids.nil?
      sudo_user_ids.each do |id|
        if users_assigned_to_requests.exists?(user_id: id)
          (users_assigned_to_requests.select { |assignment| assignment.user_id == id }).each do |assignment|
            assignment.sudo = true
          end
        else
          users_assigned_to_requests.create(sudo: true, user_id: id)
        end
      end
    end
  end

  def sudo_user_assignments
    users_assigned_to_requests.select(&:sudo)
  end
end
