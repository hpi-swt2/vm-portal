# frozen_string_literal: true

class Request < ApplicationRecord
  has_many :users_assigned_to_requests
  has_many :users, through: :users_assigned_to_requests
  belongs_to :user

  attr_accessor :sudo_user_ids

  MAX_NAME_LENGTH = 20
  MAX_CPU_CORES = 64
  MAX_RAM_MB = 256_000
  MAX_STORAGE_MB = 1_000_000

  enum status: %i[pending accepted rejected]
  validates :name,
            length: { maximum: MAX_NAME_LENGTH, message: 'only allows a maximum of %{count} characters' },
            format: { with: /\A[a-zA-Z1-9\-\s]+\z/, message: 'only letters and numbers allowed' },
            uniqueness: true
  validates :cpu_cores, :ram_mb, :storage_mb, :operating_system, :description, presence: true
  validates :cpu_cores, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: MAX_CPU_CORES }
  validates :ram_mb, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: MAX_RAM_MB }
  validates :storage_mb, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: MAX_STORAGE_MB }

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

  def reject!
    self.status = 'rejected'
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

  def sudo_users
    sudo_user_assignments.map(&:user)
  end

  def non_sudo_user_assignments
    users_assigned_to_requests - sudo_user_assignments
  end

  def create_vm
    folder = VSphere::Connection.instance.root_folder
    clusters = VSphere::Cluster.all
    folder.create_vm(cpu_cores, ram_mb, storage_mb, name, clusters.first) if clusters.first
  end

  def push_to_git
    path = PuppetParserHelper.puppet_script_path

    begin
      notice = ''
      GitHelper.open_repository(path) do |git_writer|
        git_writer.write_file('Node/' + "node_#{name}.pp", generate_puppet_node_script)
        git_writer.write_file('Name/' + "#{name}.pp", generate_puppet_name_script)
        message, notice = commit_and_notice_message(git_writer)
        git_writer.save(message)
      end
      { notice: notice }
    rescue Git::GitExecuteError
      { alert: 'Could not push to git. Please check that your ssh key and environment variables are set.' }
    end
  end

  def commit_and_notice_message(git_writer)
    if git_writer.added?
      ['Add ' + name, 'Added file and pushed to git.']
    elsif git_writer.updated?
      ['Update ' + name, 'Changed file and pushed to git.']
    else
      ['', 'Already up to date.']
    end
  end

  def generate_puppet_node_script
    admin_users = users_assigned_to_requests.select(&:sudo).to_a
    admin_users.map!(&:user)
    Puppetscript.node_script(name, admin_users, users.to_a)
  end

  def generate_puppet_name_script
    Puppetscript.name_script(name)
  end

  private

  def url(host_name)
    Rails.application.routes.url_helpers.request_url self, host: host_name
  end
end
