# frozen_string_literal: true

class NotificationsController < ApplicationController
  before_action :set_notification, only: %i[show edit update destroy mark_as_read mark_as_read_and_redirect]

  # GET /notifications
  # GET /notifications.json
  def index
    @notifications = Notification.where(user: current_user)
  end

  # GET /notifications/new
  def new
    @notification = Notification.new
  end

  # POST /notifications
  # POST /notifications.json
  def create
    @notification = Notification.new(notification_params)
    @notification.user_id = current_user.id
    @notification.read = false

    respond_to do |format|
      if @notification.save
        format.html { redirect_to notifications_path }
      else
        format.html { render :new }
      end
    end
  end

  # DELETE /notifications/1
  # DELETE /notifications/1.json
  def destroy
    @notification.destroy
    respond_to do |format|
      format.html { redirect_to dashboard_path }
      format.json { head :no_content }
    end
  end

  def mark_as_read_and_redirect
    @notification.update(read: true) unless @notification.read
    if @notification.link.present?
      redirect_to @notification.link
    else
      redirect_to dashboard_path
    end
  end

  def mark_as_read
    @notification.read = true
    respond_to do |format|
      if @notification.save
        format.html { redirect_back fallback_location: notifications_path }
      else
        format.html { redirect_back fallback_location: notifications_path, alert: 'Something went wrong.' }
      end
    end
  end

  def any?
    has_unread_notifications = Notification.where(user: current_user, read: false).any?
    respond_to do |format|
      msg = { has_unread_notifications: has_unread_notifications }
      format.json { render json: msg }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_notification
    @notification = Notification.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def notification_params
    params.require(:notification).permit(:title, :message)
  end
end
