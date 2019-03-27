# frozen_string_literal: true

class HartLogger

  def initialize(default_logger)
    @default_logger = default_logger
  end

  attr_accessor :default_logger
  delegate_missing_to :default_logger

  def error(progname = nil, &block)
    User.admin.each do |admin|
      admin.notify 'An Error occured!', progname.to_s + "\n\nPlease check the settings."
    end

    default_logger.error(progname, &block)
  end
end
