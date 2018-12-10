class DashboardController < ApplicationController
  attr_reader :notifications
  def index
    redirect_to '/users/sign_in' if current_user.nil?
    @notifications = Notification.where(user: current_user).slice(0,3)
  end
end