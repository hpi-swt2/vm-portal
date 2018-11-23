# frozen_string_literal: true

require 'vmapi.rb'
class VmController < ApplicationController
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
  end

  def show
    #request = session[:current_request]
    #if request.status = 'accepted'
      #fill(request)
    #  page.fill_in('name'), with request.name
    #end
  end

  def filling(request)
    #page.fill_in('name'), with request.name
    #page.fill_in('cpu'), with request.cpu
    #page.fill_in('ram'), with request.ram
    #page.fill_in('capacity'), with request.capacity
  end

  def fill(request)
    create(request.name, request.cpu, request.ram, request.capacity)
  end
  # This controller doesn't use strong parameters
  # https://edgeapi.rubyonrails.org/classes/ActionController/StrongParameters.html
  # Because no Active Record model is being wrapped
end
