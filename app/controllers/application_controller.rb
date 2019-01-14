# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  protect_from_forgery prepend: true

  add_flash_types :success, :danger

  def after_sign_in_path_for(_resource)
    dashboard_path
  end

  # Overwriting the sign_out redirect path method
  def after_sign_out_path_for(_resource)
    root_path
  end

  rescue_from Net::OpenTimeout, Errno::ENETUNREACH, Errno::EHOSTUNREACH, with: :error_render_method

  def error_render_method
    render(template: 'errors/timeout', status: 408) && return
  end

  def authenticate_employee
    redirect_to dashboard_path, alert: I18n.t('authorization.unauthorized') unless current_user && current_user.employee_or_admin?
  end

  def authenticate_admin
    redirect_to dashboard_path, alert: I18n.t('authorization.unauthorized') unless current_user&.admin?
  end
end
