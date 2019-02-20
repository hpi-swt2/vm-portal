# frozen_string_literal: true

def create_git_stub
  git = double
  status = double
  allow(git).to receive(:config)
  allow(git).to receive(:status) { status }
  allow(git).to receive(:add)
  allow(git).to receive(:commit_all)
  allow(git).to receive(:push)
  allow(git).to receive(:pull)
  allow(status).to receive(:added).and_return([])
  allow(status).to receive(:changed).and_return([])

  repository_name = 'test_repository_name'

  allow(GitHelper).to receive(:repository_path).and_return(File.join(Rails.root, 'private', repository_name))
  path = Puppetscript.puppet_script_path
  node_path = File.join path, 'Node'
  name_path = File.join path, 'Name'

  git_class = class_double('Git')
              .as_stubbed_const(transfer_nested_constants: true)

  allow(git_class).to receive(:clone) do
    FileUtils.mkdir_p(path) unless File.exist?(path)
    FileUtils.mkdir_p(node_path) unless File.exist?(node_path)
    FileUtils.mkdir_p(name_path) unless File.exist?(name_path)
    git
  end

  AppSetting.instance.update!(
    git_repository_url: 'test_repository_url',
    git_repository_name: repository_name,
    github_user_name: 'test_user_name',
    github_user_email: 'test@email.com'
  )

  GitStub.new(git_class, path, git, status)
end

class GitStub
  attr_reader :git, :status

  def initialize(git_class, path, git, status)
    @git_class = git_class
    @path = path
    @git = git
    @status = status
  end

  def delete
    FileUtils.rm_rf(@path) if File.exist?(@path)
  end
end
