# frozen_string_literal: true

require 'vmapi.rb'
class VmsController < ApplicationController
  attr_reader :vms

  include VmsHelper
  before_action :authenticate_admin, only: %i[archive_vm]
  before_action :authorize_vm_access, only: %i[show]

  def index
    vms = filter(current_user.admin? ? VSphere::VirtualMachine.all : current_user.vms)
    split_into_categories vms
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
    return render(template: 'errors/not_found', status: :not_found) if @vm.nil?
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

  def change_power_state
    @vm = VmApi.instance.get_vm_info(params[:id])
    VmApi.instance.change_power_state(@vm[:name], !@vm[:state])
    redirect_to root_path
  end

  def suspend_vm
    @vm = VmApi.instance.get_vm_info(params[:id])
    VmApi.instance.suspend_vm(@vm[:name])
    redirect_to action: :show, id: params[:id]
  end

  def shutdown_guest_os
    @vm = VmApi.instance.get_vm_info(params[:id])
    VmApi.instance.shutdown_guest_os(@vm[:name])
    redirect_to action: :show, id: params[:id]
  end

  def reboot_guest_os
    @vm = VmApi.instance.get_vm_info(params[:id])
    VmApi.instance.reboot_guest_os(@vm[:name])
    redirect_to action: :show, id: params[:id]
  end

  def reset_vm
    @vm = VmApi.instance.get_vm_info(params[:id])
    VmApi.instance.reset_vm(@vm[:name])
    redirect_to action: :show, id: params[:id]
  end

  # This controller doesn't use strong parameters
  # https://edgeapi.rubyonrails.org/classes/ActionController/StrongParameters.html
  # Because no Active Record model is being wrapped

  private

  def split_into_categories(vms)
    @vms = []
    @archived_vms = []
    @pending_archivation_vms = []
    vms.each do |each|
      if each.archived?
        @archived_vms << each
      elsif each.pending_archivation?
        @pending_archivation_vms << each
      else
        @vms << each
      end
    end
  end

  def filter(list)
    if no_params_set?
      list
    else
      result = []
      vm_filter.keys.each do |key|
        result += list.select { |object| vm_filter[key].call(object) } if params[key].present?
      end
      result
    end
  end

  def determine_params
    all_parameters = vm_filter.keys.map(&:to_s)
    actual_params = params.keys.map(&:to_s)
    if no_params_set?
      all_parameters
    else
      all_parameters - (all_parameters - actual_params)
    end
  end

  def no_params_set?
    all_parameters = vm_filter.keys.map(&:to_s)
    actual_params = params.keys.map(&:to_s)
    (all_parameters - actual_params).size == all_parameters.size
  end

  def vm_filter
    { up_vms: proc(&:powered_on?), down_vms: proc(&:powered_off?) }
  end

  def authorize_vm_access
    @vm = VmApi.instance.get_vm_info(params[:id])
    return unless @vm

    redirect_to vms_path if current_user.user? && !current_user.vm_infos.include?(@vm)
  end
end
