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

  def description_text(host_name)
    description = "- VM Name: #{name}\n"
    description += "- Responsible: TBD\n"
    description += comment.empty? ? '' : "- Comment: #{comment}\n"
    description += url(host_name) + "\n"
    description
  end

  def accept!
    self.status = 'accepted'
  end

  def push_to_git
    path = File.join Rails.root, 'public', 'puppet_script_temp'

    FileUtils.mkdir_p(path) unless File.exist?(path)

    begin
      g = setup_git(path)

      node_script = write_node_script(path)
      g.add(node_script)
      name_script = write_name_script(path)
      g.add(name_script)
      change_init_script

      if g.status.untracked.length == 0 && g.status.added.length != 0
        message = 'Added file and pushed to git.'
        g.commit_all("Add " + node_script_filename)
        g.push
      elsif g.status.untracked.length == 0 && g.status.changed.length != 0
        message = 'Changed file and pushed to git.'
        g.commit_all("Update " + node_script_filename)
        g.push
      else
        message = "Already up to date."
      end

      { notice: message }
    rescue Git::GitExecuteError => e
      puts e
      { alert: "Could not push to git. Please check that your ssh key and environment variables are set."}
    ensure
      FileUtils.rm_rf( path ) if File.exists?( path )
    end
  end

  def generate_puppet_node_script
    puppet_string =
        'class node_vm-%s {
    $admins = [%s]
    $users = [%s]

    realize(Accounts::Virtual[$admins], Accounts::Sudoroot[$admins])
    realize(Accounts::Virtual[$users])
}'
    admins = users_assigned_to_requests.select(&:sudo).to_a
    admins.map!(&:user)
    users = users.to_a

    admins.map! { |user| "\"#{user.first_name << '.' << user.last_name}\"" }
    users.map! { |user| "\"#{user.first_name << '.' << user.last_name}\"" }
    format(puppet_string, name, admins.join(', '), users.join(', '))
  end

  def generate_puppet_name_script
    puppet_script =
      'node \'%s\'{

    if defined( node_%s) {
                class { node_%s: }
    }
}'
    format(puppet_script, name, name, name)
  end
  private

  # TODO get credentials and config for currently logged in user
  # Clones and configures a git repository on dir.
  def setup_git(path)
    # Dir.mkdir(dir) unless File.exists?(dir)
    uri = ENV['GIT_REPOSITORY_URL']
    name = ENV['GIT_REPOSITORY_NAME']

    g = Git.clone(uri, name, :path => path)
    g.config('user.name', ENV['GITHUB_USER_NAME'])
    g.config('user.email', ENV['GITHUB_USER_EMAIL'])
    g
  end

  # Creates node_vmname.pp. If file exists, overwrite file with potentially newer content
  def write_node_script(path)
    puppet_string = generate_puppet_node_script
    path = File.join path, ENV['GIT_REPOSITORY_NAME'], 'Node', node_script_filename
    File.delete(path) if File.exists?(path)
    File.open(path, 'w') { |f| f.write(puppet_string) }
    path
  end

  # TODO file not yet created
  # Creates vmname.pp
  def write_name_script(path)
    puppet_string = generate_puppet_name_script
    path = File.join path, ENV['GIT_REPOSITORY_NAME'], 'Name', name_script_filename
    File.delete(path) if File.exists?(path)
    File.open(path, 'w') { |f| f.write(puppet_string) }
    path
  end

  # TODO logic to change init.pp for new users
  # Adapts init.pp for potential new users
  def change_init_script
  end

  def node_script_filename
    "node_#{name}.pp"
  end

  def name_script_filename
    "#{name}.pp"
  end


  def url(host_name)
    Rails.application.routes.url_helpers.request_url self, host: host_name
  end
end
