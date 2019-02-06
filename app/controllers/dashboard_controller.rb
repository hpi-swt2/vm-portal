# frozen_string_literal: true

require './app/api/v_sphere/virtual_machine'
require './app/api/v_sphere/host'

class DashboardController < ApplicationController
  attr_reader :vms, :hosts, :notifications

  def index
    redirect_to '/users/sign_in' if current_user.nil?
    @vms = current_user.nil? ? VSphere::VirtualMachine.all : VSphere::VirtualMachine.user_vms(current_user)
    @hosts = VSphere::Host.all
    @notifications = Notification.where(user: current_user).slice(0, number_of_notifications)
  end

  def number_of_notifications
    3
  end
end
