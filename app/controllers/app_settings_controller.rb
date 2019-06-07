# frozen_string_literal: true

class AppSettingsController < ApplicationController
  before_action :set_app_setting, only: %i[edit update import]
  before_action :authenticate_admin

  # GET /app_settings/1/edit
  def edit; end

  # PATCH/PUT /app_settings/1
  def update
    if @app_setting.update(app_setting_params)
      redirect_to edit_app_setting_path(@app_setting), notice: t('flash.update.notice_simple', resource: 'Settings object')
    else
      render :edit
    end
  end

  def import
    current_users = User.all.collect {|each| each.name}
    GitHelper.open_git_repository(for_write: true) {}
    initpp = File.read(File.join(Puppetscript.init_path, Puppetscript.init_file_name))
    all_initpp_users = initpp.scan(/realname\s*=>\s*'(.+?)'/).flatten
    initpp_only_users = all_initpp_users - current_users

    successful_created_users = 0

    initpp_only_users.each do |each|
      user = User.extern each
      puts 'enter'
      successful_created_users += 1 if user.persisted?
    end

    redirect_to edit_app_setting_path(@app_setting), notice: "Successfully added #{successful_created_users} users."
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
    params.require(:app_setting).permit(:git_repository_url, :git_repository_name, :git_branch, :github_user_name, :github_user_email,
                                        :vsphere_server_ip, :vsphere_server_user, :vsphere_server_password, :vsphere_root_folder,
                                        :puppet_init_path, :puppet_classes_path, :puppet_nodes_path,
                                        :email_notification_smtp_address, :email_notification_smtp_port, :email_notification_smtp_domain,
                                        :email_notification_smtp_user, :email_notification_smtp_password,
                                        :vm_archivation_timeout, :min_cpu_cores, :max_cpu_cores, :max_ram_size, :max_storage_size,
                                        :max_shown_vms)
  end
end
