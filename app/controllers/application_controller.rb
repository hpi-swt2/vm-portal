# frozen_string_literal: true

class ApplicationController < ActionController::Base
  def after_sign_in_path_for(_resource)
    vms_path
  end

  rescue_from Net::OpenTimeout, Errno::ENETUNREACH, Errno::EHOSTUNREACH, with: :error_render_method

  def error_render_method
    render(template: 'errors/timeout', status: 408) && return
  end
end
