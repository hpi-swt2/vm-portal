# frozen_string_literal: true

Airbrake.configure do |config|
  config.host = 'https://errbit-vm-portal.herokuapp.com'
  config.project_id = 1 # required, but any positive integer works
  config.project_key = ENV['ERRBIT_PROJECT_KEY'] || '7442c4230459a58a49afb8a0bcaff0a8'

  # for Rails apps
  config.environment = Rails.env
  config.ignore_environments = %w[development test]
end
