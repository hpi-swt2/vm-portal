# frozen_string_literal: true

require './app/api/v_sphere/virtual_machine'
require './app/api/v_sphere/host'

class DashboardController < ApplicationController
  attr_reader :vms, :hosts, :notifications

  include VmsHelper

  def index
    redirect_to '/users/sign_in' if current_user.nil?
    initialize_vm_categories
    filter_vm_categories current_user unless current_user.admin?
    @notifications = Notification.where(user: current_user).slice(0, number_of_notifications)
  end

  private

  def initialize_vm_categories
    @vms = VSphere::VirtualMachine.rest
    @archivable = VSphere::VirtualMachine.pending_archivation.select{ |vm| vm.archivable? }
    @revivable = VSphere::VirtualMachine.pending_revivings
  end

  def filter_vm_categories(user)
    user_vms = VSphere::VirtualMachine.user_vms(user)
    @vms = @vms.select { |vm| user_vms.include?(vm) }
    @archivable = @archivable.select { |vm| user_vms.include?(vm) }
    @revivable = @revivable.select { |vm| user_vms.include?(vm) }
  end

  def max_shown_vms
    10
  end

  def number_of_notifications
    3
  end
end
