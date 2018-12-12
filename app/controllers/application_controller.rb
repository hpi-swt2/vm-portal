# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  def after_sign_in_path_for(_resource)
    vms_path
  end

  rescue_from Net::OpenTimeout, Errno::ENETUNREACH, Errno::EHOSTUNREACH, with: :error_render_method

  def error_render_method
    render(template: 'errors/timeout', status: 408) && return
  end

  def authenticate_wimi
    redirect_to root_path, alert: I18n.t('authorization.unauthorized') unless current_user && (current_user.admin? || current_user.wimi?)
  end

  def authenticate_admin
    redirect_to root_path, alert: I18n.t('authorization.unauthorized') unless current_user&.admin?
  end
end
