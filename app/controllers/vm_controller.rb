# frozen_string_literal: true

require 'vmapi.rb'
class VmController < ApplicationController
  include RequestsHelper
  def index
    @vms = VmApi.new.all_vms
  end

  def destroy
    # params[:id] is actually the name of the vm, since the vsphere backend doesn't identify vms by IDs
    VmApi.new.delete_vm(params[:id])
  end

  def create
    VmApi.new.create_vm(params[:cpu], params[:ram], params[:capacity], params[:name])
    redirect_to action: :index
  end

  def new
    @vm = VmApi.new
    @request = !(params[:request].nil?) ? Request.find(params[:request]) : default_request
  end

  def show
  end

  private

    def default_request
      { name: 'VM', cpu_cores: 1, ram_mb: 1000, storage_mb: 1000 }
    end
end
