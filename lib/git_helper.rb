# frozen_string_literal: true

module GitHelper
  def self.open_repository(path)
    FileUtils.mkdir_p(path) unless File.exist?(path)
    git_writer = GitWriter.new(path)
    yield git_writer
  end

  class GitWriter
    def initialize(path)
      @path = path
      if File.exist?(File.join(path, '.git'))
        open_git
        @git.pull
      else
        setup_git
      end
    end

    def write_file(file_name, file_content)
      path = File.join @path, file_name
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

    def save(message)
      commit_and_push(message) if added? || updated?
    end

    private

    def setup_git
      uri = ENV['GIT_REPOSITORY_URL']
      name = ENV['GIT_REPOSITORY_NAME']

      @git = Git.clone(uri, name, path: File.join(@path, '..'))
      @git.config('user.name', ENV['GITHUB_USER_NAME'])
      @git.config('user.email', ENV['GITHUB_USER_EMAIL'])
    end

    def open_git
      @git = Git.open(@path)
      @git.config('user.name', ENV['GITHUB_USER_NAME'])
      @git.config('user.email', ENV['GITHUB_USER_EMAIL'])
    end

    def commit_and_push(message)
      @git.commit_all(message)
      @git.push
    end
  end
end
