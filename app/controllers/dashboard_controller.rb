# frozen_string_literal: true

require 'vmapi.rb'
class DashboardController < ApplicationController
  attr_reader :vms, :hosts

  def index
    redirect_to '/users/sign_in' if current_user.nil?
    @vms = VmApi.instance.all_vms
    @hosts = VmApi.instance.all_hosts
    @notifications = Notification.where(user: current_user).slice(0, 3)
  end
end
