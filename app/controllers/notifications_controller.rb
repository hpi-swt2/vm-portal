# frozen_string_literal: true

class NotificationsController < ApplicationController
  before_action :set_notification, only: %i(show edit update destroy mark_as_read)

  # GET /notifications
  # GET /notifications.json
  def index
    @notifications = Notification.all
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
        format.html { redirect_to notifications_path, notice: 'Notification was successfully created.' }
        format.json { render :show, status: :created, location: @notification }
      else
        format.html { render :new }
        format.json { render json: @notification.errors, status: :unprocessable_entity }
      end
    end
  end


  # DELETE /notifications/1
  # DELETE /notifications/1.json
  def destroy
    @notification.destroy
    respond_to do |format|
      format.html { redirect_to notifications_url, notice: 'Notification was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def mark_as_read
    @notification.read = true
    respond_to do |format|
      if @notification.save
        format.html { redirect_to notifications_path }
      else
        format.html { redirect_to notifications_path, alert: 'Something went wrong.'}
      end
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
