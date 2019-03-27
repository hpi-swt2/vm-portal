# frozen_string_literal: true

class HartFormatter < Rails.env == 'production' ? ::Logger::Formatter : ActiveSupport::Logger::SimpleFormatter
  def call(severity, timestamp, progname, msg)
    if severity == 'ERROR'
      User.admin.each do |admin|
        admin.notify 'An Error occured!', msg.to_s, type: :error
      end
    end

    super(severity, timestamp, progname, msg)
  end
end
