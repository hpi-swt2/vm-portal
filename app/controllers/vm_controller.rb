require 'vmapi.rb'
class VmController < ApplicationController
  def index
    @vms = VmApi.new.all_vms
  end

  def show
  end

  def update
  end

  def destroy
  end

  def create
  end

  def new
  end

  def edit
  end
end
