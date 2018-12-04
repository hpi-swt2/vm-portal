# frozen_string_literal: true

require 'vmapi.rb'
class DashboardController < ApplicationController
  attr_reader :vms, :hosts

  def index
    redirect_to '/users/sign_in' if current_user.nil?
    @vms = VmApi.new.all_vms
    @hosts = VmApi.new.all_hosts
  end
end
