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

  rescue_from Net::OpenTimeout, Errno::ENETUNREACH, Errno::EHOSTUNREACH, with: :render_timeout
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  def render_timeout
    render(template: 'errors/timeout', status: 408) && nil
  end

  def render_not_found
    render(template: 'errors/not_found', status: 404) && nil
  end

  def authenticate_employee
    redirect_to dashboard_path, alert: I18n.t('authorization.unauthorized') unless current_user&.employee_or_admin?
  end

  def authenticate_admin
    redirect_to dashboard_path, alert: I18n.t('authorization.unauthorized') unless current_user&.admin?
  end
end
