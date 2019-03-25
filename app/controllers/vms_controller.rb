# frozen_string_literal: true

require './app/api/v_sphere/virtual_machine'

class VmsController < ApplicationController
  rescue_from RbVmomi::Fault, with: :not_enough_resources

  attr_reader :vms

  include VmsHelper
  before_action :assign_vm, except: %i[update_config update edit index]
  before_action :assign_config, only: %i[update_config update edit edit_config ]
  before_action :authenticate_admin, only: %i[archive_vm edit_config update_config]
  before_action :authorize_vm_access, only: %i[show edit update]
  before_action :authenticate_root_user_or_admin, only: %i[change_power_state suspend_vm shutdown_guest_os reboot_guest_os reset_vm]

  def index
    initialize_vm_categories
    filter_vm_categories current_user unless current_user.admin?
  end

  def show; end

  def edit_config
    @vm.ensure_config
  end

  def update_config
    if @vm_config.update(config_params)
      redirect_to requests_path, notice: 'Successfully updated configuration'
    else
      redirect_to requests_path, notice: 'Could not update the configuration'
    end
  end

  def edit
    @sudo_user_ids = @vm_config.sudo_users.map(&:id)
    @non_sudo_user_ids = @vm_config.users.map(&:id)
    @configuration = @vm_config
  end

  def update
    old_users = @vm_config.all_users
    old_sudo_users = @vm_config.sudo_users

    if @vm_config.update config_params
      notify_changed_users(old_sudo_users, @vm_config.sudo_users, true, @vm_config.name)
      notify_changed_users(old_users, @vm_config.users, false, @vm_config.name)
      redirect_to vm_path(@vm_config.name)
    else
      flash[:error] = 'Description couldn\'t be saved.'
      redirect_to edit_vm_path(@vm_config.name)
    end
  end

  def request_vm_archivation
    return if @vm.archived? || @vm.pending_archivation?

    @vm.users.each do |each|
      each.notify("VM #{@vm.name} archiving requested",
                  "The VM will soon be archived and it will be shut down.\nIf you still need this VM you can stop the archiving of this VM within #{ArchivationRequest.timeout_readable}.",
                  url_for(controller: :vms, action: 'show', id: @vm.name))
    end
    @vm.set_pending_archivation

    redirect_to controller: :vms, action: 'show', id: @vm.name
    @admin_ids = User.admin.pluck(:id)
    ApplicationJob.set(wait: ArchivationRequest.timeout).perform_later(@admin_ids, @vm.name, url_for(controller: :vms, action: 'show', id: @vm.name))
  end

  def request_vm_revive
    return if @vm.pending_reviving?

    User.admin.each do |each|
      each.notify("VM #{@vm.name} revival requested",
                  'The VM has to be revived.',
                  url_for(controller: :vms, action: 'show', id: @vm.name))
    end

    @vm.set_pending_reviving
    redirect_to controller: :vms, action: 'show', id: @vm.name
  end

  def stop_archiving
    @vm.set_revived
  end

  def archive_vm
    return if @vm.archived?

    @vm.set_archived

    # inform users
    @vm.users.each do |each|
      each.notify("VM #{@vm.name} has been archived", '', url_for(controller: :vms, action: 'show', id: @vm.name))
    end

    redirect_to controller: :vms, action: 'index', id: @vm.name
  end

  def revive_vm
    @vm.set_revived
    @vm.power_on

    @vm.users.each do |each|
      each.notify("VM #{@vm.name} has been revived", '', url_for(controller: :vms, action: 'show', id: @vm.name))
    end

    redirect_to controller: :vms, action: :edit_config, id: @vm.name
  end

  def change_power_state
    @vm.change_power_state
    redirect_back(fallback_location: root_path)
  end

  def suspend_vm
    @vm.suspend_vm
    redirect_back(fallback_location: root_path)
  end

  def shutdown_guest_os
    @vm.shutdown_guest_os
    redirect_back(fallback_location: root_path)
  end

  def reboot_guest_os
    @vm.reboot_guest_os
    redirect_back(fallback_location: root_path)
  end

  def reset_vm
    @vm.reset_vm
    redirect_back(fallback_location: root_path)
  end

  private

  def config_params
    params.require(:vm_info).permit(:description, :ip, :dns, sudo_user_ids: [], user_ids: [])
  end

  def initialize_vm_categories
    @vms = VSphere::VirtualMachine.rest
    @archived_vms = VSphere::VirtualMachine.archived
    @pending_archivation_vms = VSphere::VirtualMachine.pending_archivation
    @pending_reviving_vms = VSphere::VirtualMachine.pending_revivings
  end

  def filter_vm_categories(user)
    user_vms = VSphere::VirtualMachine.user_vms(user)
    @vms = @vms.select { |vm| user_vms.include?(vm) }
    @archived_vms = @archived_vms.select { |vm| user_vms.include?(vm) }
    @pending_archivation_vms = @pending_archivation_vms.select { |vm| user_vms.include?(vm) }
    @pending_reviving_vms = @pending_reviving_vms.select { |vm| user_vms.include?(vm) }
  end

  def authorize_vm_access
    configuration = VirtualMachineConfig.find_by_name params[:id]

    redirect_to vms_path unless current_user.admin? || (configuration&.all_users&.include?(current_user))
  end

  def authenticate_root_user_or_admin
    configuration = VirtualMachineConfig.find_by_name params[:id]

    redirect_to vms_path unless current_user.admin? ||
                                configuration && (configuration.sudo_users.include?(current_user) || configuration.responsible_users.include?(current_user))
  end

  def not_enough_resources(exception)
    redirect_back(fallback_location: root_path)
    flash[:alert] = exception.message
  end

  def assign_vm
    @vm = VSphere::VirtualMachine.find_by_name(params[:id])
    redirect_back fallback_location: vms_path, alert: 'This Virtual machine could not be found!' if @vm.nil?
  end

  def assign_config
    @vm_config = VirtualMachineConfig.find_by_name params[:id]
    redirect_back fallback_location: vms_path, alert: 'This virtual machine could not be found in the database!' if @vm_config.nil?
  end
end
