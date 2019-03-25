# frozen_string_literal: true

class NotificationsController < ApplicationController
  before_action :set_notification, only: %i[destroy mark_as_read mark_as_read_and_redirect]

  # GET /notifications
  def index
    @notifications = Notification.where(user: current_user)
  end

  # DELETE /notifications/1
  def destroy
    if @notification.destroy
      notice = 'Notification was successfully deleted.'
    else
      alert = 'Error while deleting notification.'
    end
    redirect_back fallback_location: notifications_path, notice: notice, alert: alert
  end
  
  # GET /notifications/1/mark_as_read_and_redirect
  def mark_as_read_and_redirect
    @notification.update(read: true) unless @notification.read
    if @notification.link.present?
      redirect_to @notification.link
    else
      redirect_back fallback_location: notifications_path
    end
  end
  
  # GET /notifications/1/mark_as_read
  def mark_as_read
    @notification.read = true
    if @notification.save
      redirect_back fallback_location: notifications_path
    else
      redirect_back fallback_location: notifications_path, alert: 'Something went wrong.'
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
