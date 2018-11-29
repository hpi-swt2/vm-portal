# frozen_string_literal: true

require 'vmapi.rb'
class ServerController < ApplicationController
  attr_reader :hosts

  def index
    @hosts = filter VmApi.instance.all_hosts
    @is_connected = VmApi.instance.connected?
    @parameters = determine_params
    if @is_connected
      flash.discard
    else
      flash[:danger] = 'You seem to have lost connection to the HPI network :('
    end
  end

  def new; end

  def show
    @host = VmApi.new.get_host(params[:id])
  end

  private

  def filter(list)
    if no_params_set? then list
    else
      result = []
      host_filter.keys.each do |key|
        result += list.select { |object| host_filter[key].call(object) } if params[key].present?
      end
      result
    end
  end

  def determine_params
    all_parameters = host_filter.keys.map(&:to_s)
    actual_params = params.keys.map(&:to_s)
    if no_params_set?
    then all_parameters
    else all_parameters - (all_parameters - actual_params)
    end
  end

  def no_params_set?
    all_parameters = host_filter.keys.map(&:to_s)
    actual_params = params.keys.map(&:to_s)
    parameter_count = (all_parameters - actual_params).size
    parameter_count == all_parameters.size
  end

  def host_filter
    { up_hosts: proc { |host| host[:connectionState] == 'connected' }, down_hosts: proc { |host| host[:connectionState] != 'connected' } }
  end
end
