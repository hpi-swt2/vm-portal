# frozen_string_literal: true

require 'vmapi.rb'
class VmsController < ApplicationController
  attr_reader :vms

  include VmsHelper
  before_action :authenticate_admin, only: %i[archive_vm]
  before_action :authorize_vm_access, only: %i[show]

  def index
    initialize_vm_categories
    filter_vm_categories current_user unless current_user.admin?
    @parameters = determine_params
  end

  def destroy
    # params[:id] is actually the name of the vm, since the vsphere backend doesn't identify vms by IDs
    # VmApi.instance.delete_vm(params[:id])
  end

  def create
    VmApi.instance.create_vm(params[:cpu], params[:ram], params[:capacity], params[:name])
    redirect_to action: :index
  end

  def new
    @request = !params[:request].nil? ? Request.find(params[:request]) : default_render
  end

  def show
    render(template: 'errors/not_found', status: :not_found) if @vm.nil?
  end

  def request_vm_archivation
    @vm = VSphere::VirtualMachine.find_by_name params[:id]
    return if !@vm || @vm.archived? || @vm.pending_archivation?

    User.admin.each do |each|
      each.notify("VM #{@vm.name} has been requested to be archived",
                  "The VM has been shut down and has to be archived.\n#{url_for(controller: :vms, action: 'show', id: @vm.name)}")
    end
    @vm.users.each do |each|
      each.notify("Your VM #{@vm.name} has been requested to be archived",
                  "The VM has been shut down and will soon be archived.\nPlease inform your administrator in the case of any objections\n" +
                  url_for(controller: :vms, action: 'show', id: @vm.name))
    end
    @vm.set_pending_archivation

    redirect_to controller: :vms, action: 'show', id: @vm.name
  end

  def request_vm_revive
    @vm = VSphere::VirtualMachine.find_by_name(params[:id])
    return if !@vm || @vm.pending_reviving?

    User.admin.each do |each|
      each.notify("VM #{@vm.name} has been requested to be revived",
                  "The VM has to be revived.\n#{url_for(controller: :vms, action: 'show', id: @vm.name)}")
    end

    @vm.set_pending_reviving
    redirect_to controller: :vms, action: 'show', id: @vm.name
  end

  def archive_vm
    @vm = VSphere::VirtualMachine.find_by_name params[:id]
    return if !@vm || @vm.archived?

    @vm.set_archived

    # inform users
    @vm.users.each do |each|
      each.notify("VM #{@vm.name} has been archived", url_for(controller: :vms, action: 'show', id: @vm.name))
    end

    redirect_to controller: :vms, action: 'index', id: @vm.name
  end

  def revive_vm
    @vm = VSphere::VirtualMachine.find_by_name(params[:id])
    @vm.set_revived
    @vm.power_on

    @vm.users.each do |each|
      each.notify("VM #{@vm.name} has been revived", url_for(controller: :vms, action: 'show', id: @vm.name))
    end

    redirect_to controller: :vms, action: 'index', id: @vm.name
  end

  def change_power_state
    @vm = VmApi.instance.get_vm_info(params[:id])
    VmApi.instance.change_power_state(@vm[:name], !@vm[:state])
    redirect_back(fallback_location: root_path)
  end

  def suspend_vm
    @vm = VmApi.instance.get_vm_info(params[:id])
    VmApi.instance.suspend_vm(@vm[:name])
    redirect_back(fallback_location: root_path)
  end

  def shutdown_guest_os
    @vm = VmApi.instance.get_vm_info(params[:id])
    VmApi.instance.shutdown_guest_os(@vm[:name])
    redirect_back(fallback_location: root_path)
  end

  def reboot_guest_os
    @vm = VmApi.instance.get_vm_info(params[:id])
    VmApi.instance.reboot_guest_os(@vm[:name])
    redirect_back(fallback_location: root_path)
  end

  def reset_vm
    @vm = VmApi.instance.get_vm_info(params[:id])
    VmApi.instance.reset_vm(@vm[:name])
    redirect_back(fallback_location: root_path)
  end

  # This controller doesn't use strong parameters
  # https://edgeapi.rubyonrails.org/classes/ActionController/StrongParameters.html
  # Because no Active Record model is being wrapped

  private

  def initialize_vm_categories
    @vms = VSphere::VirtualMachine.rest
    @archived_vms = VSphere::VirtualMachine.archived
    @pending_archivation_vms = VSphere::VirtualMachine.pending_archivation
    @pending_reviving_vms = VSphere::VirtualMachine.pending_revivings
  end

  def filter_vm_categories(user)
    @vms = @vms.select { |each| each.belongs_to user }
    @archived_vms = @archived_vms.select { |each| each.belongs_to user }
    @pending_archivation_vms = @pending_archivation_vms.select { |each| each.belongs_to user }
    @pending_reviving_vms = @pending_reviving_vms.select { |each| each.belongs_to user }
  end

  def authorize_vm_access
    @vm = VmApi.instance.get_vm_info(params[:id])
    return unless @vm

    redirect_to vms_path if current_user.user? && !current_user.vm_infos.include?(@vm)
  end
end
