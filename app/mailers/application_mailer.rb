# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'application@vm-portal.com'
  layout 'mailer'
end
