# frozen_string_literal: true

require 'time'

module GitHelper
  def self.open_git_repository(path: Puppetscript.puppet_script_path, for_write: false)
    FileUtils.mkdir_p(path) unless File.exist?(path)
    git_writer = GitWriter.new(path, for_write)
    yield git_writer
  end

  def self.reset
    FileUtils.rm_rf repository_path
    GitWriter.new repository_path, true
  end

  def self.repository_path
    File.join(Rails.root, 'private', AppSetting.instance.git_repository_name)
  end

  class GitWriter
    def initialize(path, for_write)
      @path = path
      initialize_settings

      if File.exist?(File.join(@path, '.git'))
        @git = Git.open(@path)
        pull if for_write || !pulled_last_minute?
      else
        @git = Git.clone(@repository_url, @repository_name, path: File.dirname(@path))
        pull # this will set the correct branch
      end
      set_github_credentials
    end

    def write_file(file_name, file_content)
      path = File.join @path, file_name
      File.delete(path) if File.exist?(path)
      directory_path = File.dirname(path)
      FileUtils.mkdir_p(directory_path) unless File.exist?(directory_path)
      File.open(path, 'w') {|f| f.write(file_content)}
      @git.add(path)
    end

    def added?
      @git.status.added.any?
    end

    def updated?
      @git.status.changed.any?
    end

    def save(message)
      commit_and_push(message) if added? || updated?
    end

    private

    def initialize_settings
      @repository_url = AppSetting.instance.git_repository_url
      @repository_name = AppSetting.instance.git_repository_name
      @repository_branch = AppSetting.instance.git_branch
      @user_name = AppSetting.instance.github_user_name
      @user_email = AppSetting.instance.github_user_email
    end

    def set_github_credentials
      @git.config('user.name', @user_name)
      @git.config('user.email', @user_email)
    end

    def pull
      @git.checkout(@repository_branch)
      path = last_pulled_path
      File.open(path, 'w') {|file| file.write(Time.now)}
      @git.pull('origin', @repository_branch)
    end

    def pulled_last_minute?
      path = last_pulled_path
      return false unless File.exist?(path)

      last_date = Time.parse(File.open(path, &:readline))
      difference = Time.now - last_date

      difference < 60
    end

    def last_pulled_path
      File.join(@path, '.last_pull')
    end

    def commit_and_push(message)
      @git.commit_all(message)
      @git.push('origin', @repository_branch)
    end
  end
end
