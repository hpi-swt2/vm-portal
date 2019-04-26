# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'
require './app/helpers/hart_formatter'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module VmPortal
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Load files in lib
    config.eager_load_paths << Rails.root.join('lib')

    # set custom formatter to support creating Notifications when an error is logged
    config.log_formatter = HartFormatter.new

    # Use normal JS (default), not coffeescript
    # https://guides.rubyonrails.org/configuring.html#configuring-generators
    config.generators.javascript_engine = :js

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    config.before_configuration do
      env_file = Rails.root.join('config', 'environment_variables.yml').to_s

      if File.exist?(env_file)
        configuration = YAML.load_file(env_file)&.[](Rails.env)
        configuration&.each do |key, value|
          # you can only assign strings to ENV-Variables
          ENV[key.to_s] = value.to_s
        end
      end
    end
  end
end
