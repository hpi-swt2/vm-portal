# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'noreply@vm-portal.com'
  layout 'mailer'
end
