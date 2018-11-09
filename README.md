# VM-Portal

This rails app enables managing of VMs via VSphere

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
