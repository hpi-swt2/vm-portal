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

  enum status: %i[pending accepted rejected]
  validates :name,
            length: { maximum: MAX_NAME_LENGTH, message: 'only allows a maximum of %{count} characters' },
            format: { with: /\A[a-z0-9\-]+\z/, message: 'only allows lowercase letters, numbers and "-"' }
  validate :name_uniqueness
  validates :responsible_users, :project_id, :cpu_cores, :ram_gb, :storage_gb, :description, presence: true
  validates_with VmValidator

  with_options if: :port_forwarding do |request|
    request.validates :port, presence: true, numericality: { only_integer: true }
    request.validates :application_name, presence: true
  end

  def name_uniqueness
    errors.add(:name, ': vSphere already has a VM with the same name') if VSphere::VirtualMachine.all.map(&:name).include?(name)
    errors.add(:name, ': There is already a request with the same name') if (Request.pending + Request.accepted - [self]).map(&:name).include?(name)
  end

  def description_text
    description  = "- VM Name: #{name}\n"
    description += "- Responsible: #{responsible_users.first.name}\n"
    description += comment.empty? ? '' : "- Comment: #{comment}\n"
    description
  end

  def description_url(host_name)
    Rails.application.routes.url_helpers.request_url self, host: host_name
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
    return nil, 'VM could not be created, as there are no clusters available in vSphere!' if clusters.empty?

    cluster = clusters.sample
    return nil, 'VM could not be created, there is no network available in the cluster' if cluster.networks.empty?

    warning = push_to_git_with_warnings
    [create_vm_in_cluster(cluster), warning]
  end

  def create_vm_in_cluster(cluster)
    vm = VSphere::Connection.instance.root_folder.create_vm(cpu_cores, gibi_to_mibi(ram_gb), gibi_to_kibi(storage_gb), name, cluster)
    vm.ensure_config.update(
      responsible_users: responsible_users,
      project: project,
      description: description
    )
    vm.move_into_correct_subfolder
    vm
  end

  def push_to_git_with_warnings
    push_to_git
    nil # no warning
  rescue Git::GitExecuteError => error
    logger.error error
    "Your VM was created, but users could not be associated with the VM! Push to git failed, error:\n\"#{error.message}\""
  end

  # Error handling has been moved into push_to_git_with_warnings to provide easier feedback for the user
  def push_to_git
    GitHelper.open_git_repository(for_write: true) do |git_writer|
      git_writer.write_file(Puppetscript.node_file_name(name), generate_puppet_node_script)
      git_writer.write_file(Puppetscript.class_file_name(name), generate_puppet_name_script)
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
    admin_users = users_assigned_to_requests.select(&:sudo).map(&:user)
    # Every responsible person has sudo rights on the VM
    admin_users = (admin_users + responsible_users).uniq
    non_admin_users = (users + responsible_users).uniq
    Puppetscript.node_script(name, admin_users, non_admin_users)
  end

  def generate_puppet_name_script
    Puppetscript.name_script(name)
  end

  private

  def gibi_to_mibi(gibi)
    gibi * 1024
  end

  def gibi_to_kibi(gibi)
    gibi * 1024**2
  end
end
