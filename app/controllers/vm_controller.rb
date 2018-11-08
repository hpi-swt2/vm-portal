# frozen_string_literal: true

require 'vmapi.rb'
class VmController < ApplicationController
  def index
    @vms = VmApi.new.all_vms
  end

  def show; end

  def update; end

  def destroy
    VmApi.new.delete_vm(params[:id])
  end

  def create
    puts params
    VmApi.new.create_vm(params[:cpu], params[:ram], params[:capacity], params[:name])
    redirect_to action: :index
  end

  def new; end

  def edit; end
end
