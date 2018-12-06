class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def hpi
    @user = User.from_omniauth(request.env['omniauth.auth'])

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: 'Login successful')
    else
      redire
      render 'Error'
    end
  end

  def failure
    redirect_to vm_index_path
  end
end