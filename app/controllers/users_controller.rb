class UsersController < ApplicationController
  authorize_resource
  before_action :find_user, only: [:show, :edit, :update, :destroy]

  def index
    @users = User.by_name.all
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(strong_params)
    if @user.save
      redirect_to @user, notice: t("thing.created", thing: @user.thing)
    else
      render :new
    end
  end

  def update
    if @user.update(strong_params)
      redirect_to @user, notice: t("thing.updated", thing: @user.thing)
    else
      render :edit
    end
  end

  def destroy
    @user.destroy
    redirect_to users_path, alert: t("thing.deleted", thing: @user.thing)
  end

  private

  def find_user
    @user = User.find(params[:id])
  end

  def strong_params
    params.require(:user).permit(:handle, :password, :first_name, :last_name, :role)
  end
end
