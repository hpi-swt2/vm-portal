# frozen_string_literal: true

module OperatingSystemsHelper
  def operating_system_options
    options = OperatingSystem.all.map(&:name)
    options.unshift 'none'
    options.push 'other(write in Comment)'
  end
end
