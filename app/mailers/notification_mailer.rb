class NotificationMailer < ApplicationMailer
	default from: 'notifications@vm-portal.com'
 
  def notify_email()
    @user = params[:user]
    @message = params[:message]
    @title = params[:title]
    mail(to: @user.email, subject: @title)
  end
end
