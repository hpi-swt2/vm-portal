class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def hpi
    set_flash_message(:notice, :success, kind: 'Login successful')
  end

  def failure
    set_flash_message(:notice, :success, kind: 'Login not successful')
  end
end