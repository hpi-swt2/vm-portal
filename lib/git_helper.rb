# frozen_string_literal: true

module GitHelper
  def self.write_to_repository(path, name)
    FileUtils.mkdir_p(path) unless File.exist?(path)
    git_writer = GitWriter.new(path, name)
    begin
      yield git_writer
    ensure
      FileUtils.rm_rf(path) if File.exist?(path)
    end
    message = git_writer.save
    message
  end

  class GitWriter
    def initialize(path, name)
      @path = path
      @name = name
      @git = setup_git(path)
    end

    def write_file(file_name, file_content)
      path = File.join @path, ENV['GIT_REPOSITORY_NAME'], file_name
      File.delete(path) if File.exist?(path)
      File.open(path, 'w') { |f| f.write(file_content) }
      @git.add(path)
    end

    def added?
      @git.status.added.any?
    end

    def updated?
      @git.status.changed.any?
    end

    def save
      if added?
        commit_and_push('Add ' + @name)
        'Added file and pushed to git.'
      elsif updated?
        commit_and_push('Update ' + @name)
        'Changed file and pushed to git.'
      else
        'Already up to date.'
      end
    end

    private

    def setup_git(path)
      # Dir.mkdir(dir) unless File.exists?(dir)
      uri = ENV['GIT_REPOSITORY_URL']
      name = ENV['GIT_REPOSITORY_NAME']

      git = Git.clone(uri, name, path: path)
      git.config('user.name', ENV['GITHUB_USER_NAME'])
      git.config('user.email', ENV['GITHUB_USER_EMAIL'])
      git
    end

    def commit_and_push(message)
      @git.commit_all(message)
      @git.push
    end
  end
end
