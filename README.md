# VM-Portal

This [Ruby on Rails](https://rubyonrails.org/) application enables managing of VMs via [VMware vSphere](https://en.wikipedia.org/wiki/VMware_vSphere). [![License](http://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/hpi-swt2/vm-portal/blob/master/LICENSE)

Branch | Travis CI  | CodeClimate
------ | ---------- | -------------
master  | [![Build Status](https://travis-ci.com/hpi-swt2/vm-portal.svg?branch=master)](https://travis-ci.com/hpi-swt2/vm-portal) | [![Maintainability](https://api.codeclimate.com/v1/badges/bc93de388c2d75383166/maintainability)](https://codeclimate.com/github/hpi-swt2/vm-portal/maintainability) |

## Local Setup

* `bundle install` Install the required Ruby gem dependencies defined in the Gemfile
* Check `database.yml` for the correct database config (for development we recommend SQLite) 
* `rails db:create db:migrate db:seed` Setup database, run migrations, seed the database with defaults
* `rails s` Start the Rails development server (By default runs on _localhost:3000_)
* `bundle exec rspec` Run all the tests (using the [RSpec](http://rspec.info/) test framework)

If you want to use a VM to setup the project (e.g. when on Windows), we recommend [Vagrant](https://www.vagrantup.com/) in combination with [Virtualbox](https://www.virtualbox.org/).
Please keep in mind that this method may lead to a loss in performance, due to the added abstraction layer.

## Developer guide
1. Testing  
* To run the full test suite: `bundle exec rspec`.
* For fancier test running use option `-f doc` and specify
 what tests to run by `-e 'search keyword in test name'`.
2. Linting  
* Rubocop is installed, run `bundle exec rubocop` to find problems.
* Use `--auto-correct` to fix what can be fixed automatically.

### Development Commands
* `bundle exec rails db:migrate RAILS_ENV=development && bundle exec rails db:migrate RAILS_ENV=test` Migrate dbs
* `bundle exec rails assets:clobber && bundle exec rails assets:precompile` Redo asset generation
* `bundle exec rspec spec/<rest_of_file_path>.rb` Specify a folder or test file to run
* `rails c --sandbox` Test out some code in the Rails console without changing any data
* `rails g migration DoSomething` Create migration _db/migrate/*_DoSomething.rb_.
* `rails dbconsole` Starts the CLI of the database you're using
* `bundle exec rails routes` Show all the routes (and their names) of the application
* `bundle exec rails about` Show stats on current Rails installation, including version numbers
* `bundle exec rspec --profile` examine how much time individual tests take
