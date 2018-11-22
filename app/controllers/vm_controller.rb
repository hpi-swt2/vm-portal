# frozen_string_literal: true

require 'vmapi.rb'
class VmController < ApplicationController
  def index
    @vms = VmApi.new.all_vms
    @hosts = VmApi.new.all_hosts

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
    @host = VmApi.new.get_host(params[:id].gsub '%2E', '.')
  end

  # This controller doesn't use strong parameters
  # https://edgeapi.rubyonrails.org/classes/ActionController/StrongParameters.html
  # Because no Active Record model is being wrapped
end
