class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def hpi
    @user = User.from_omniauth(request.env['omniauth.auth'])

    if @user.persisted?
      set_flash_message!(:success, :success, :kind => "HPI OpenID Connect")
      sign_in_and_redirect @user, event: :authentication
    else
      set_flash_message!(:danger, :failure, :kind => "HPI OpenID Connect", :reason => "Login failed")
      redirect_to root_path
    end
  end

  def failure
    set_flash_message!(:danger, :failure, :kind => "HPI OpenID Connect", :reason => "Login failed")
    redirect_to root_path
  end
end