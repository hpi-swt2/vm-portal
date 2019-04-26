# frozen_string_literal: true

# Abstract superclass for Servers and VM objects
class Machine < ApplicationRecord
  self.abstract_class = true

  def commit_message(git_writer)
    if git_writer.added?
      'Add ' + name
    elsif git_writer.updated?
      'Update ' + name
    else
      ''
    end
  end

  def node_script
    Puppetscript.node_script(name, (sudo_users + responsible_users).uniq, all_users)
  end

  def all_users
    (users + sudo_users + responsible_users).uniq
  end

  private

  def read_users
    begin
      GitHelper.open_git_repository do
        remote_users = Puppetscript.read_node_file(name)
        @users = remote_users[:users] || [] if @users.nil?
        @sudo_users = remote_users[:admins] || [] if @sudo_users.nil?
      end
    rescue Git::GitExecuteError, RuntimeError => e
      Rails.logger.error(e)
      # ensure users and sudo_users are always valid arrays
      @users = [] if @users.nil?
      @sudo_users = [] if @sudo_users.nil?
    end
    @users -= @sudo_users
    @sudo_users -= responsible_users
  end

  def save_users
    GitHelper.open_git_repository for_write: true do |git_writer|
      name_script = Puppetscript.name_script name
      write_puppetscripts git_writer, name_script, node_script
    end
  rescue Git::GitExecuteError, RuntimeError => e
    Rails.logger.error(e)
    # update local user assignments again to reflect the written status (if available)
    @users = @sudo_users = nil
    read_users
  end

  def write_puppetscripts(git_writer, name_script, node_script)
    git_writer.write_file(Puppetscript.class_file_name(name), name_script)
    git_writer.write_file(Puppetscript.node_file_name(name), node_script)
    message = commit_message(git_writer)
    git_writer.save(message)
  end

  def convert_to_user(user_or_id)
    user.is_a? User ? user : User.find(user_or_id)
  end
end