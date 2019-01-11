# frozen_string_literal: true

class Application < Rails::Application
  config.action_dispatch.default_headers.merge!(
    'Cache-Control' => 'no-store, no-cache'
  )
end
