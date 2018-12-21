# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_current_user, only: [:edit]

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])

    if @user.update(user_params)
      redirect_to @user
    else
      render :edit
    end
  end

  def update_role
    @user = User.find(params[:id])
    if @user.update(role: params[:role])
      render :index
    end
  end

  private

  def user_params
    params.require(:user).permit(:ssh_key)
  end

  def authenticate_current_user
    @user = User.find(params[:id])
    redirect_to @user unless current_user == @user
  end
end
