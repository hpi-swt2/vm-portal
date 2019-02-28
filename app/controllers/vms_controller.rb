# frozen_string_literal: true

require './app/api/v_sphere/virtual_machine'

class VmsController < ApplicationController
  rescue_from RbVmomi::Fault, with: :not_enough_resources

  attr_reader :vms

  include VmsHelper
  before_action :authenticate_admin, only: %i[archive_vm edit_config update_config]
  before_action :authorize_vm_access, only: %i[show edit update]
  before_action :authenticate_root_user_or_admin, only: %i[change_power_state suspend_vm shutdown_guest_os reboot_guest_os reset_vm]

  def index
    initialize_vm_categories
    filter_vm_categories current_user unless current_user.admin?
  end

  def show
    render(template: 'errors/not_found', status: :not_found) if @vm.nil?
  end

  def edit_config
    @vm = VSphere::VirtualMachine.find_by_name params[:id]
    @vm.ensure_config
  end

  def update_config
    @config = VirtualMachineConfig.find_by_name params[:id]
    if @config
      if @config.update(config_params)
        redirect_to requests_path, notice: 'Successfully updated configuration'
      else
        redirect_to requests_path, notice: 'Could not update the configuration'
      end
    else
      flash[:alert] = 'Configuration could not be found!'
      redirect_to controller: :vms, action: 'index'
    end
  end

  def edit
    return render(template: 'errors/not_found', status: :not_found) if @vm.nil?

    @sudo_user_ids = @vm.sudo_users.map(&:id)
    @non_sudo_user_ids = @vm.users.map(&:id)
    @description = @vm.ensure_config.description
  end

  def update
    prepare_info_params
    notify_changed_users(@vm.sudo_users.map(&:id), info_params[:sudo_user_ids].map(&:to_i), true, @vm.name)
    notify_changed_users(@vm.users.map(&:id), info_params[:non_sudo_user_ids].map(&:to_i), false, @vm.name)
    @vm.sudo_users = info_params[:sudo_user_ids]
    @vm.users = info_params[:non_sudo_user_ids]
    @vm.ensure_config.description = info_params[:description]
    unless @vm.config.save
      flash[:error] = 'Description couldn\'t be saved.'
      redirect_to edit_vm_path(@vm.name)
    end

    redirect_to vm_path(@vm.name)
  end

  def request_vm_archivation
    @vm = VSphere::VirtualMachine.find_by_name params[:id]
    return if !@vm || @vm.archived? || @vm.pending_archivation?

    @vm.users.each do |each|
      each.notify("Your VM #{@vm.name} has been requested to be archived",
                  "The VM will soon be archived and for that it will then be shut down.\nIf you still need this VM you can stop the archiving of this VM within #{ArchivationRequest.timeout_readable}.",
                  url_for(controller: :vms, action: 'show', id: @vm.name))
    end
    @vm.set_pending_archivation

    redirect_to controller: :vms, action: 'show', id: @vm.name
    @admin_ids = User.admin.pluck(:id)
    ApplicationJob.set(wait: ArchivationRequest.timeout).perform_later(@admin_ids, @vm.name, url_for(controller: :vms, action: 'show', id: @vm.name))
  end

  def request_vm_revive
    @vm = VSphere::VirtualMachine.find_by_name(params[:id])
    return if !@vm || @vm.pending_reviving?

    User.admin.each do |each|
      each.notify("VM #{@vm.name} has been requested to be revived",
                  'The VM has to be revived.',
                  url_for(controller: :vms, action: 'show', id: @vm.name))
    end

    @vm.set_pending_reviving
    redirect_to controller: :vms, action: 'show', id: @vm.name
  end

  def stop_archiving
    @vm = VSphere::VirtualMachine.find_by_name params[:id]
    @vm.set_revived
  end

  def archive_vm
    @vm = VSphere::VirtualMachine.find_by_name params[:id]
    return if !@vm || @vm.archived?

    @vm.set_archived

    # inform users
    @vm.users.each do |each|
      each.notify("VM #{@vm.name} has been archived", '', url_for(controller: :vms, action: 'show', id: @vm.name))
    end

    redirect_to controller: :vms, action: 'index', id: @vm.name
  end

  def revive_vm
    @vm = VSphere::VirtualMachine.find_by_name(params[:id])
    @vm.set_revived
    @vm.power_on

    @vm.users.each do |each|
      each.notify("VM #{@vm.name} has been revived", '', url_for(controller: :vms, action: 'show', id: @vm.name))
    end

    redirect_to controller: :vms, action: 'index', id: @vm.name
  end

  def change_power_state
    @vm = VSphere::VirtualMachine.find_by_name(params[:id])
    @vm.change_power_state
    redirect_back(fallback_location: root_path)
  end

  def suspend_vm
    @vm = VSphere::VirtualMachine.find_by_name(params[:id])
    @vm.suspend_vm
    redirect_back(fallback_location: root_path)
  end

  def shutdown_guest_os
    @vm = VSphere::VirtualMachine.find_by_name(params[:id])
    @vm.shutdown_guest_os
    redirect_back(fallback_location: root_path)
  end

  def reboot_guest_os
    @vm = VSphere::VirtualMachine.find_by_name(params[:id])
    @vm.reboot_guest_os
    redirect_back(fallback_location: root_path)
  end

  def reset_vm
    @vm = VSphere::VirtualMachine.find_by_name(params[:id])
    @vm.reset_vm
    redirect_back(fallback_location: root_path)
  end

  # This controller doesn't use strong parameters
  # https://edgeapi.rubyonrails.org/classes/ActionController/StrongParameters.html
  # Because no Active Record model is being wrapped

  private

  def prepare_info_params
    return unless params[:vm_info]

    params[:vm_info][:sudo_user_ids] ||= @vm.sudo_users.map(&:id)
    params[:vm_info][:non_sudo_user_ids] ||= (@vm.users - @vm.sudo_users).map(&:id)
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
    @vm = VSphere::VirtualMachine.find_by_name params[:id]
    return unless @vm

    redirect_to vms_path unless current_user.admin? || @vm.users.include?(current_user)
  end

  def info_params
    params.require(:vm_info).permit(:description, sudo_user_ids: [], non_sudo_user_ids: [])
  end

  def config_params
    params.require(:virtual_machine_config).permit(:ip, :dns)
  end

  def authenticate_root_user_or_admin
    @vm = VSphere::VirtualMachine.find_by_name(params[:id])
    return unless @vm

    redirect_to vms_path unless current_user.admin? || @vm.sudo_users.include?(current_user)
  end

  def not_enough_resources(exception)
    redirect_back(fallback_location: root_path)
    flash[:alert] = exception.message
  end
end
