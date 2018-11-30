# frozen_string_literal: true

# Configuration for using FactoryBot in rspec
# https://stackoverflow.com/questions/48091582/
# https://github.com/thoughtbot/factory_bot_rails

require 'factory_bot'

RSpec.configure do |config|
  # Include FactoryBot functions
  config.include FactoryBot::Syntax::Methods
end
