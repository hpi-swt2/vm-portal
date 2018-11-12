# VM-Portal

This [Ruby on Rails](https://rubyonrails.org/) application enables managing of VMs via [VMware vSphere](https://en.wikipedia.org/wiki/VMware_vSphere). [![License](http://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/hpi-swt2/vm-portal/blob/master/LICENSE)

Branch | Travis CI  | CodeClimate
------ | ---------- | -------------
master  | [![Build Status](https://travis-ci.com/hpi-swt2/vm-portal.svg?branch=master)](https://travis-ci.com/hpi-swt2/vm-portal) | [![Maintainability](https://api.codeclimate.com/v1/badges/bc93de388c2d75383166/maintainability)](https://codeclimate.com/github/hpi-swt2/vm-portal/maintainability) |

## Local Setup

* `bundle install` Install the required Ruby gem dependencies defined in the Gemfile
* Check `config/database.yml` for the correct database config (for development we recommend SQLite)
* `rails db:migrate db:seed` Setup database, run migrations, seed the database with defaults
* `rails s` Start the Rails development server (By default runs on _localhost:3000_)
* `bundle exec rspec` Run all the tests (using the [RSpec](http://rspec.info/) test framework)

## Setup using Vagrant (Virtual Machine)

If you want to use a VM to setup the project (e.g. when on Windows), we recommend [Vagrant](https://www.vagrantup.com/) in combination with [Virtualbox](https://www.virtualbox.org/). The `Vagrantfile` in the project root contains the needed configuration. If you have trouble starting the VM, try changing the parameters to adapt to your hardware.
Please keep in mind that this method may lead to a loss in performance, due to the added abstraction layer.

### Start VM
* `vagrant up` Download and start the VM
* `vagrant ssh` Login using SSH

### Inside the VM
* `cd hpi-swt2`
* `bundle install` Update dependencies
* `rails db:migrate db:seed` Run migrations, update database
* `rails s -b 0` Start the rails server, the -b part is necessary since the app is running in a VM and would otherwise drop the requests coming from the host OS
* `exit` Exit SSH session

### Stop VM

* `vagrant halt` Shuts down the VM
* `vagrant global-status` Shows status of all Vagrant VMs


## Developer guide

### Development Commands

1. Setup
* `bundle exec rails db:migrate RAILS_ENV=development && bundle exec rails db:migrate RAILS_ENV=test` Migrate dbs
* `bundle exec rails assets:clobber && bundle exec rails assets:precompile` Redo asset generation
2. Testing
* To run the full test suite: `bundle exec rspec`.
* For fancier test running use option `-f doc` 
* `bundle exec rspec spec/<rest_of_file_path>.rb` Specify a folder or test file to run
* specify what tests to run dynamically by `-e 'search keyword in test name'`
3. Linting
* Rubocop is installed, run `bundle exec rubocop` to find problems.
* Use `--auto-correct` to fix what can be fixed automatically.
4. Debugging
* `rails c --sandbox` Test out some code in the Rails console without changing any data
 `rails dbconsole` Starts the CLI of the database you're using
* `bundle exec rails routes` Show all the routes (and their names) of the application
* `bundle exec rails about` Show stats on current Rails installation, including version numbers
* `bundle exec rspec --profile` examine how much time individual tests take
5. Generating
* `rails g migration DoSomething` Create migration _db/migrate/*_DoSomething.rb_.

