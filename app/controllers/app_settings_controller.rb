# frozen_string_literal: true

class AppSettingsController < ApplicationController
  before_action :set_app_setting, only: %i[edit update]
  before_action :authenticate_admin

  # GET /app_settings/1/edit
  def edit; end

  # PATCH/PUT /app_settings/1
  # PATCH/PUT /app_settings/1.json
  def update
    respond_to do |format|
      if @app_setting.update(app_setting_params)
        format.html { redirect_to edit_app_setting_path(@app_setting), notice: 'HART Settings were successfully updated.' }
        format.json { render :edit, status: :ok, location: @app_setting }
      else
        format.html { render :edit }
        format.json { render json: @app_setting.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_app_setting
    @app_setting = AppSetting.find(params[:id])
  end

  def authenticate_admin
    redirect_to dashboard_path, alert: I18n.t('authorization.unauthorized') unless current_user&.admin?
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def app_setting_params
    params.require(:app_setting).permit(:git_repository_url, :git_repository_name, :github_user_name, :github_user_email,
                                        :vsphere_server_ip, :vsphere_server_user, :vsphere_server_password, :vsphere_root_folder,
                                        :puppet_init_path, :puppet_classes_path, :puppet_nodes_path,
                                        :email_notification_smtp_address, :email_notification_smtp_port, :email_notification_smtp_domain,
                                        :email_notification_smtp_user, :email_notification_smtp_password,
                                        :vm_archivation_timeout)
  end
end
