# frozen_string_literal: true

# When running in production mode use the default `Formatter`, which outputs all information
# When running outside of production, e.g. in development, use `SimpleFormatter`,
# which only displays the message, suppressing PID and timestamp
# https://www.rubydoc.info/github/rails/rails/ActiveSupport/Logger/SimpleFormatter
base_logger = Rails.env == 'production' ? ActiveSupport::Logger::Formatter : ActiveSupport::Logger::SimpleFormatter

class HartFormatter < base_logger
  def call(severity, timestamp, progname, msg)
    if severity == 'ERROR'
      User.admin.each do |admin|
        admin.notify 'An Error occured!', msg.to_s, type: :error
      end
    end

    super(severity, timestamp, progname, msg)
  end
end
