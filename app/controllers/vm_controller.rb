# frozen_string_literal: true

require 'vmapi.rb'
class VmController < ApplicationController

  attr :vms, :hosts

  def index
    @vms = filter_vms VmApi.new.all_vms
    @hosts = filter_hosts VmApi.new.all_hosts
    @parameters = determine_params
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

  def show_host
    @host = VmApi.new.get_host(params[:id])
  end

  # This controller doesn't use strong parameters
  # https://edgeapi.rubyonrails.org/classes/ActionController/StrongParameters.html
  # Because no Active Record model is being wrapped

  private
  def filter_vms(vms)
    filter(vms, :vm_filter)
  end

  def filter_hosts(hosts)
    filter(hosts, :host_filter)
  end

  def filter(list, filter)
    if no_params_set? then list
    else
      result = []
      send(filter).keys.each do |key|
        if params[key].present?
          result += list.select{ |object| send(filter)[key].call(object) }
        end
      end
      result
    end
  end

  def determine_params
    all_parameters = (vm_filter.keys + host_filter.keys).map! { |x| x.to_s }
    actual_params = params.keys.map { |x| x.to_s }
    if no_params_set? 
    then all_parameters
    else all_parameters - (all_parameters - actual_params)
    end
  end

  def no_params_set?
    all_parameters = (vm_filter.keys + host_filter.keys).map! { |x| x.to_s }
    actual_params = params.keys.map { |x| x.to_s }
    (all_parameters - actual_params).size == all_parameters.size
  end

  def vm_filter
    {up_vms: Proc.new { |vm| vm[:state] }, down_vms: Proc.new { |vm| !vm[:state] } }
  end

  def host_filter
    {up_hosts: Proc.new { |host| host[:connectionState] == 'connected' }, down_hosts: Proc.new { |host| host[:connectionState] != 'connected' } }
  end
end
