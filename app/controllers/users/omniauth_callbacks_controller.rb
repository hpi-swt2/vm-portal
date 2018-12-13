class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def hpi
    @user = User.from_omniauth(request.env['omniauth.auth'])

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
    else
      flash[:danger] = 'Login failed'
      redirect_to root_path
    end
  end

  def failure
    flash[:danger] = 'Login failed'
    redirect_to root_path
  end
end