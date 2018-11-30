# frozen_string_literal: true

require 'vmapi.rb'
class VmController < ApplicationController
  attr_reader :vms

  def index
    @vms = filter VmApi.instance.all_vms
    @parameters = determine_params
    if VmApi.instance.connected?
      flash.discard
    else
      flash[:danger] = 'You seem to have lost connection to the HPI network :('
    end
  end

  def destroy
    # params[:id] is actually the name of the vm, since the vsphere backend doesn't identify vms by IDs
    VmApi.instance.delete_vm(params[:id]) if VmApi.instance.connected?
  end

  def create
    VmApi.instance.create_vm(params[:cpu], params[:ram], params[:capacity], params[:name]) if VmApi.instance.connected?
    redirect_to action: :index
  end

  def new
    @request = !params[:request].nil? ? Request.find(params[:request]) : default_request
  end

  def show
    if VmApi.instance.connected?
      flash.discard
      @vm = VmApi.instance.get_vm(params[:id])
    else
      flash[:danger] = 'You seem to have lost connection to the HPI network :('
    end
  end

  # This controller doesn't use strong parameters
  # https://edgeapi.rubyonrails.org/classes/ActionController/StrongParameters.html
  # Because no Active Record model is being wrapped

  private

  def filter(list)
    if no_params_set? then list
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
    then all_parameters
    else all_parameters - (all_parameters - actual_params)
    end
  end

  def no_params_set?
    all_parameters = vm_filter.keys.map(&:to_s)
    actual_params = params.keys.map(&:to_s)
    (all_parameters - actual_params).size == all_parameters.size
  end

  def vm_filter
    { up_vms: proc { |vm| vm[:state] }, down_vms: proc { |vm| !vm[:state] } }
  end

  def default_request
    { name: 'VM', cpu_cores: 1, ram_mb: 1000, storage_mb: 1000 }
  end
end
