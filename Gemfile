# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.5.0'

# Gems to install: faker, shoulda matchers
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.1'
# Use sqlite3 and postgres as the database for Active Record
gem 'sqlite3' # development and testing
# Use Puma as the app server
gem 'puma', '~> 3.11'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'mini_racer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Flexible authentication solution for Rails with Warden
# https://github.com/plataformatec/devise
gem 'devise'
# Role management, minimal authorization through OO design and pure Ruby classes
# https://github.com/varvet/pundit
gem 'pundit'

# Fancy default views and javascript helpers https://github.com/twbs/bootstrap-rubygem
gem 'bootstrap', '~> 4.1.3'
gem 'devise-bootstrap-views', '~> 1.0'
gem 'devise-i18n'
gem 'jquery-rails'

# Ruby interface to the VMware vSphere API
# https://github.com/vmware/rbvmomi
gem 'rbvmomi'

# Mina for deployment 
# Have a look in the tutorial:
# https://github.com/lnikell/wiki/wiki/Deploy-rails-application-with-Mina,-Nginx-and-Puma
gem 'mina', require: false
gem 'mina-puma', require: false,  github: 'untitledkingdom/mina-puma'
# Adds support for multiple stages, https://github.com/endoze/mina-multistage
gem 'mina-multistage', require: false
# Tail production logs, https://github.com/windy/mina-logs
# $ mina logs # tail -f log/production.log
gem 'mina-logs', require: false
gem 'execjs', require: false

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'rspec-rails', '~> 3.8'
  # State of the art fixtures https://github.com/thoughtbot/factory_bot_rails
  gem 'factory_bot_rails'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'web-console', '>= 3.3.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  # Easy linting https://github.com/rubocop-hq/rubocop
  gem 'rubocop', require: false
  gem 'rubocop-rspec'
  # Much nicer error pages https://github.com/BetterErrors/better_errors
  gem 'better_errors'
  gem 'binding_of_caller'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  # Easy installation and use of chromedriver to run system tests with Chrome
  gem 'chromedriver-helper'
  # More fun while testing, easy sample data and oneline tests for rails functionality
  gem 'faker', git: 'https://github.com/stympy/faker.git', branch: 'master'
  gem 'rails-controller-testing'
  gem 'shoulda-matchers', '4.0.0.rc1'
end

group :production do
  gem 'pg'      # production database runs on postgres
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
