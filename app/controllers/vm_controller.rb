# frozen_string_literal: true

require 'vmapi.rb'
class VmController < ApplicationController
  attr_reader :vms
  before_action :set_globals, only: [:index]

  def index
    fetch_vms
    @parameters = determine_params
  rescue StandardError
    flash.now[:error] = "You're not connected to the HPI network"
  end

  def destroy
    # params[:id] is actually the name of the vm, since the vsphere backend doesn't identify vms by IDs
    VmApi.new.delete_vm(params[:id])
  end

  def create
    VmApi.new.create_vm(params[:cpu], params[:ram], params[:capacity], params[:name])
    redirect_to action: :index
  end

  def new; end

  def show
    @vm = VmApi.new.get_vm(params[:id])
  end

  # This controller doesn't use strong parameters
  # https://edgeapi.rubyonrails.org/classes/ActionController/StrongParameters.html
  # Because no Active Record model is being wrapped

  private

  def fetch_vms
    @vms = filter VmApi.new.all_vms
  end

  def set_globals
    @vms = @parameters = []
  end

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
end
