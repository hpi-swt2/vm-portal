class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def hpi
    @user = User.from_omniauth(request.env['omniauth.auth'])
    flash[:danger] = 'Login failed'

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
    else
      redirect_to root_path
    end
  end

  def failure
    redirect_to root_path
  end
end