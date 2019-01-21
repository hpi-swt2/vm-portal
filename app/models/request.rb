# frozen_string_literal: true

class Request < ApplicationRecord
  has_many :users_assigned_to_requests
  has_many :users, through: :users_assigned_to_requests
  belongs_to :user
  has_and_belongs_to_many :responsible_users, class_name: 'User', join_table: 'requests_responsible_users'

  attr_accessor :sudo_user_ids

  MAX_NAME_LENGTH = 20
  MAX_CPU_CORES = 64
  MAX_RAM_MB = 256_999
  MAX_STORAGE_MB = 999_999

  enum status: %i[pending accepted rejected]
  validates :name,
            length: { maximum: MAX_NAME_LENGTH, message: 'only allows a maximum of %{count} characters' },
            format: { with: /\A[a-zA-Z1-9\-\s]+\z/, message: 'only letters and numbers allowed' },
            uniqueness: true
  validates :cpu_cores, :ram_mb, :storage_mb, :operating_system, :description, presence: true
  validates :cpu_cores, numericality: { greater_than: 0, less_than: MAX_CPU_CORES }
  validates :ram_mb, numericality: { greater_than: 0, less_than_or_equal_to: MAX_RAM_MB }
  validates :storage_mb, numericality: { greater_than: 0, less_than_or_equal_to: MAX_STORAGE_MB }
  validates :responsible_users, presence: true

  def description_text(host_name)
    description  = "- VM Name: #{name}\n"
    description += "- Responsible: TBD\n"
    description += comment.empty? ? '' : "- Comment: #{comment}\n"
    description += url(host_name) + "\n"
    description
  end

  def accept!
    self.status = 'accepted'
  end

  def assign_sudo_users(sudo_user_ids)
    sudo_user_ids&.each do |id|
      assignment = users_assigned_to_requests.find { |an_assignment| an_assignment.user_id == id.to_i }
      if !assignment.nil?
        assignment.update_attribute(:sudo, true)
      else
        users_assigned_to_requests.create(sudo: true, user_id: id)
      end
    end
  end

  def sudo_user_assignments
    users_assigned_to_requests.select(&:sudo)
  end

  def non_sudo_user_assignments
    users_assigned_to_requests - sudo_user_assignments
  end

  private

  def url(host_name)
    Rails.application.routes.url_helpers.request_url self, host: host_name
  end
end
