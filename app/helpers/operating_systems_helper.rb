# frozen_string_literal: true

module OperatingSystemsHelper
  def operating_system_options
    options = ['none']
    OperatingSystem.all.each do |operating_system|
      options << operating_system.name
    end
    options << 'other(write in Comment)'
  end
end
