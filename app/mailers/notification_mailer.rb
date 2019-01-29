class NotificationMailer < ApplicationMailer
	default from: 'notifications@vm-portal.com'
 
  def notify_email()
    @user = params[:user]
    @message = params[:text]
    mail(to: @user.email, subject: 'You shall be notified')
  end
end
