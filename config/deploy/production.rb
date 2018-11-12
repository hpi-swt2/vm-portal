# Configuration for mina production deployment.
# Loaded from config/deploy.rb

# The hostname to SSH to (master)
set :domain, 'vm-swt-hrmt-master.eaalab.hpi.uni-potsdam.de'
# Path to deploy into
set :deploy_to, '/var/www/vm-swt-hrmt-master.eaalab.hpi.uni-potsdam.de/'
# Git repo to clone from. (needed by mina/git)
set :repository, 'git@github.com:hpi-swt2/vm-portal.git'
# Branch name to deploy. (needed by mina/git)
set :branch, 'master'
# Slack stage identifier
set :slack_stage, 'master'

