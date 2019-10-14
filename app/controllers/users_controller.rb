class UsersController < ApplicationController
  load_and_authorize_resource

  def index
    @users = User.by_name.all
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(resource_params)
    if @user.save
      redirect_to @user, notice: t("thing.created", thing: @user.thing)
    else
      render :new
    end
  end

  def update
    if @user.update(resource_params)
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

  def resource_params
    params.require(:user).permit(:handle, :password, :first_name, :last_name, :role)
  end
end
