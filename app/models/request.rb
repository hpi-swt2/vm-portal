# frozen_string_literal: true

class Request < ApplicationRecord
  has_many :users_assigned_to_requests
  has_many :users, through: :users_assigned_to_requests
  belongs_to :user

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

  def push_to_git
    path = File.join Rails.root, 'public', 'puppet_script_temp'
    FileUtils.mkdir_p(path) unless File.exist?(path)
    begin
      message = write_to_git(path)
      { notice: message }
    rescue Git::GitExecuteError
      { alert: 'Could not push to git. Please check that your ssh key and environment variables are set.' }
    ensure
      FileUtils.rm_rf(path) if File.exist?(path)
    end
  end

  def write_to_git(path)
    git = setup_git(path)
    write_files(git, path)
    message = perform_git_action(git)
    message
  end

  def generate_puppet_node_script
    puppet_string =
      'class node_vm-%s {
          $admins = [%s]
          $users = [%s]

          realize(Accounts::Virtual[$admins], Accounts::Sudoroot[$admins])
          realize(Accounts::Virtual[$users])
      }'
    users_string, admins_string = generate_users
    format(puppet_string, name, admins_string, users_string)
  end

  def generate_puppet_name_script
    puppet_script =
      'node \'vm-%s\'{

          if defined( node_vm-%s) {
                      class { node_vm-%s: }
          }
      }'
    format(puppet_script, name, name, name)
  end

  private

  def generate_users
    admin_users = users_assigned_to_requests.select(&:sudo).to_a
    admin_users.map!(&:user)
    [generate_user_array(admin_users), generate_user_array(users.to_a)]
  end

  def generate_user_array(users)
    users.map! { |user| "\"#{user.first_name << '.' << user.last_name}\"" }
    users.join(', ')
    users
  end

  # Clones and configures a git repository on dir.
  def setup_git(path)
    # Dir.mkdir(dir) unless File.exists?(dir)
    uri = ENV['GIT_REPOSITORY_URL']
    name = ENV['GIT_REPOSITORY_NAME']

    git = Git.clone(uri, name, path: path)
    git.config('user.name', ENV['GITHUB_USER_NAME'])
    git.config('user.email', ENV['GITHUB_USER_EMAIL'])
    git
  end

  def write_files(git, path)
    node_script = write_node_script(path)
    git.add(node_script)
    name_script = write_name_script(path)
    git.add(name_script)
    change_init_script
  end

  # Creates node_vmname.pp. If file exists, overwrite file with potentially newer content
  def write_node_script(path)
    puppet_string = generate_puppet_node_script
    path = File.join path, ENV['GIT_REPOSITORY_NAME'], 'Node', node_script_filename
    File.delete(path) if File.exist?(path)
    File.open(path, 'w') { |f| f.write(puppet_string) }
    path
  end

  # TODO: file not yet created
  # Creates vmname.pp
  def write_name_script(path)
    puppet_string = generate_puppet_name_script
    path = File.join path, ENV['GIT_REPOSITORY_NAME'], 'Name', name_script_filename
    File.delete(path) if File.exist?(path)
    File.open(path, 'w') { |f| f.write(puppet_string) }
    path
  end

  # TODO: logic to change init.pp for new users
  # Adapts init.pp for potential new users
  def change_init_script; end

  def node_script_filename
    "node_#{name}.pp"
  end

  def name_script_filename
    "#{name}.pp"
  end

  def perform_git_action(git)
    if !git.status.added.empty?
      commit_and_push('Add ' + node_script_filename)
      'Added file and pushed to git.'
    elsif !git.status.changed.empty?
      commit_and_push('Update ' + node_script_filename)
      'Changed file and pushed to git.'
    else
      'Already up to date.'
    end
  end

  def commit_and_push(message)
    git.commit_all(message)
    git.push
  end

  def url(host_name)
    Rails.application.routes.url_helpers.request_url self, host: host_name
  end
end
