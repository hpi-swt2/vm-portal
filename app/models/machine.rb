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

end