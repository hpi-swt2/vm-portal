# Configuration for mina dev deployment.
# Loaded from config/deploy.rb

# The hostname to SSH to (dev)
set :domain, 'vm-swt-hrmt-dev.eaalab.hpi.uni-potsdam.de'
# Path to deploy into
set :deploy_to, '/var/www/vm-swt-hrmt-master.eaalab.hpi.uni-potsdam.de/'
# Git repo to clone from. (needed by mina/git)
set :repository, 'git@github.com:hpi-swt2/vm-portal.git'
# Branch name to deploy. (needed by mina/git)
set :branch, 'dev'
# Slack stage identifier
set :slack_stage, 'dev'

