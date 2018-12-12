# frozen_string_literal: true

class LandingController < ApplicationController
  skip_before_action :authenticate_user!
  def index
    if current_user.nil?
      redirect_to '/users/sign_in'
    else
      redirect_to :dashboard

    end
  end
end
