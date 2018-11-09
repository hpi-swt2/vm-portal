# VM-Portal

This rails app enables managing of VMs via VSphere

## Local Setup

* `bundle install` Install the required Ruby gem dependencies defined in the Gemfile
* Check `database.yml` for the correct database config (for development we recommend SQLite) 
* `rails db:create db:migrate db:seed` Setup database, run migrations, seed the database with defaults
* `rails s` Start the Rails development server (By default runs on _localhost:3000_)
* `bundle exec rspec` Run all the tests (using the [RSpec](http://rspec.info/) test framework)

## Setup using Vagrant (Virtual Machine)

If you want to use a VM to setup the project (e.g. when on Windows), we recommend [Vagrant](https://www.vagrantup.com/).
Please keep in mind that this method may lead to a loss in performance, due to the added abstraction layer.

```
vagrant up # bring up the VM
vagrant ssh # login using SSH
cd hpi-swt2
echo "gem: --no-document" >> ~/.gemrc # disable docs for gems
bundle install # install dependencies
gem install pg # required for Postgres usage
cp config/database.psql.yml config/database.yml # in case you want to use Postgres
cp config/database.sqlite.yml config/database.yml # in case you want to user SQLite
exit # restart the session, required step
vagrant ssh # reconnect to the VM
cd hpi-swt2
rails s -b 0 # start the rails server
# the -b part is necessary since the app is running in a VM and would
# otherwise drop the requests coming from the host OS
```

## Developer guide
1. Testing  
* To run the full test suite: `bundle exec rspec`.
* For fancier test running use option `-f doc` and specify
 what tests to run by `-e 'search keyword in test name'`.
2. Linting  
* Rubocop is installed, run `bundle exec rubocop` to find problems.
* Use `--auto-correct` to fix what can be fixed automatically.
