require 'mina/rails'
require 'mina/git'
require 'mina/rvm'
require 'mina/puma'
require 'mina/slack'

# For help in making your deploy script, see the Mina documentation:
# https://github.com/mina-deploy/mina/tree/master/docs

# Basic settings:
set :application_name, 'VM-Management Portal'
# The hostname to SSH to.
set :domain, 'vm-swt-hrmt-master.eaalab.hpi.uni-potsdam.de'
# Path to deploy into.
set :deploy_to, '/var/www/vm-swt-hrmt-master.eaalab.hpi.uni-potsdam.de'
# Git repo to clone from. (needed by mina/git)
set :repository, 'git@github.com:hpi-swt2/vm-portal.git'
# Branch name to deploy. (needed by mina/git)
set :branch, 'master'

# Optional settings:
set :user, 'hrmtadm'          # Username in the server to SSH to.
set :identity_file, '/home/hrmtadm/.ssh/id_rsa'
#   set :port, '30000'           # SSH port number.
#   set :forward_agent, true     # SSH forward_agent.

# Shared dirs and files will be symlinked into the app-folder by the 'deploy:link_shared_paths' step.
# Some plugins already add folders to shared_dirs like `mina/rails` add `public/assets`, `vendor/bundle` and many more
# run `mina -d` to see all folders and files already included in `shared_dirs` and `shared_files`
# set :shared_dirs, fetch(:shared_dirs, []).push('public/assets')
# set :shared_files, fetch(:shared_files, []).push('config/database.yml', 'config/secrets.yml')

set :shared_dirs, fetch(:shared_dirs, []).push('log', 'tmp/pids', 'tmp/sockets', 'public/uploads')
set :shared_files, fetch(:shared_files, []).push('config/database.yml', 'config/secrets.yml', 'config/puma.rb', 'config/master.key')
set :rvm_use_path, '/usr/local/rvm/scripts/rvm'
#set :linked_files, %w{config/master.key}

# Settings for Slack Integration
# Documentation: https://github.com/krichly/mina-slack
set :slack_hook, 'https://hooks.slack.com/services/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' # Slack hook URL
set :slack_username, 'Deploy Bot' # displayed as name of message sender
set :slack_emoji, ':cloud:' # will be used as the avatar for the message
set :slack_stage, 'master' # will be used to specify the deployment environment


# This task is the environment that is loaded for all remote run commands, such as
# `mina deploy` or `mina rake`.
task :remote_environment do
  # For those using RVM, use this to load an RVM version@gemset.
  # invoke :'rvm:use', 'ruby-1.9.3-p125@default'
  invoke :'rvm:use', 'ruby-2.5.0@default'
end

# Put any custom commands you need to run at setup
# All paths in `shared_dirs` and `shared_paths` will be created on their own.
task :setup do
  invoke :'rails:db_create'
  invoke :'puma:start'
end

desc "Deploys the current version to the server."
task :deploy do
  # uncomment this line to make sure you pushed your local branch to the remote origin
  # invoke :'git:ensure_pushed'
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    comment "Deploying #{fetch(:repository)} (#{fetch(:branch)}) to #{fetch(:domain)}"
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    #invoke :'rvm:load_env_vars'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    command %{#{fetch(:rails)} db:seed}
    invoke :'rails:assets_precompile'
    invoke :'deploy:cleanup'

    on :launch do
      invoke :'puma:phased_restart'
      invoke :'slack:postinfo'
    end
  end

  # you can use `run :local` to run tasks on local machine before of after the deploy scripts
  # run(:local){ say 'done' }
end

desc "Restarts the puma server"
task :restart => :remote_environment do
 invoke :'puma:stop'
 invoke :'puma:start'
end
