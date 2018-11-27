require 'vmapi.rb'
class DashboardController < ApplicationController
  attr_reader :vms, :hosts

  def index
    @vms = VmApi.new.all_vms
    @hosts = VmApi.new.all_hosts
  end
end
