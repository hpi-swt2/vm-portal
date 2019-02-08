# frozen_string_literal: true

module EnvironmentVariablesExample
  class Application < Rails::Application
    config.before_configuration do
      env_file = Rails.root.join('config', 'environment_variables.yml').to_s

      if File.exist?(env_file)
        YAML.load_file(env_file)[Rails.env].each do |key, value|
          # you can only assign strings to ENV-Variables
          ENV[key.to_s] = value.to_s
        end
      end

      config.action_mailer.smtp_settings = {
        address: ENV['EMAIL_NOTIFICATIONS_SMTP_ADDRESS'],
        port: ENV['EMAIL_NOTIFICATIONS_SMTP_PORT'].to_i,
        domain: ENV['EMAIL_NOTIFICATIONS_SMTP_DOMAIN'],
        user_name: ENV['EMAIL_NOTIFICATIONS_SMTP_USER'],
        password: ENV['EMAIL_NOTIFICATIONS_SMTP_PASSWORD'],
        authentication: :plain
        # enable_starttls_auto: true
      }
    end
  end
end
