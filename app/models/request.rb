# frozen_string_literal: true

class Request < ApplicationRecord
  has_many :users_assigned_to_requests
  has_many :users, through: :users_assigned_to_requests
  belongs_to :user
  belongs_to :project
  has_and_belongs_to_many :responsible_users, class_name: 'User', join_table: 'requests_responsible_users'

  before_save do
    users_assigned_to_requests.each(&:save)
  end

  attr_accessor :sudo_user_ids

  MAX_NAME_LENGTH = 20
  MAX_CPU_CORES = 64
  MAX_RAM_GB = 256
  MAX_STORAGE_GB = 1_000

  enum status: %i[pending accepted rejected]
  validates :name,
            length: { maximum: MAX_NAME_LENGTH, message: 'only allows a maximum of %{count} characters' },
            format: { with: /\A[a-z0-9\-]+\z/, message: 'only letters and numbers allowed' },
            uniqueness: true
  validates :responsible_users, :project_id, :cpu_cores, :ram_gb, :storage_gb, :operating_system, :description, presence: true
  validates :cpu_cores, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: MAX_CPU_CORES }
  validates :ram_gb, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: MAX_RAM_GB }
  validates :storage_gb, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: MAX_STORAGE_GB }
  with_options if: :port_forwarding do |request|
    request.validates :port, presence: true, numericality: { only_integer: true }
    request.validates :application_name, presence: true
  end

  def description_text(host_name)
    description  = "- VM Name: #{name}\n"
    description += "- Responsible: #{responsible_users.first.name}\n"
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
    assign_attributes(users_assigned_to_requests: users_assigned_to_requests - sudo_user_assignments)
    sudo_user_ids&.each do |id|
      assignment = users_assigned_to_requests.find { |an_assignment| an_assignment.user_id == id.to_i }
      if assignment.nil?
        users_assigned_to_requests.new(sudo: true, user_id: id)
      else
        assignment.assign_attributes(sudo: true)
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
    clusters = VSphere::Cluster.all
    return nil, nil unless clusters.first

    warning = nil
    begin
      push_to_git
    rescue Git::GitExecuteError => e
      logger.error(e)
      warning = "Your VM was created, but users could not be associated with the VM! Push to git failed, error: \"#{e.message}\""
    end
    [create_vm_in_cluster(clusters.first), warning]
  end

  def create_vm_in_cluster(cluster)
    vm = VSphere::Connection.instance.root_folder.create_vm(cpu_cores, gibi_to_mibi(ram_gb), gibi_to_kibi(storage_gb), name, cluster)
    vm.ensure_config.responsible_users = responsible_users
    vm.config.project = project
    vm.config.description = description
    vm.config.save
    vm.move_into_correct_subfolder
    vm
  end

  # Error handling has been moved into create_vm to provide easier feedback for the user
  def push_to_git
    GitHelper.open_repository(Puppetscript.puppet_script_path, for_write: true) do |git_writer|
      git_writer.write_file(File.join('Node', "node-#{name}.pp"), generate_puppet_node_script)
      git_writer.write_file(File.join('Name', "#{name}.pp"), generate_puppet_name_script)
      git_writer.save(commit_message(git_writer))
    end
  end

  def commit_message(git_writer)
    if git_writer.added?
      'Add ' + name
    elsif git_writer.updated?
      'Update ' + name
    else
      ''
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

  def gibi_to_mibi(gibi)
    gibi * 1024
  end

  def gibi_to_kibi(gibi)
    gibi * 1024**2
  end
end
