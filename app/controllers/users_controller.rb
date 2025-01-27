class UsersController < ApplicationController
  load_and_authorize_resource

  def create
    if @user.save
      redirect_to @user, notice: success("created")
      journal "User", "create", @user.id
    else
      failure @user
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @user.update(resource_params)
      redirect_to @user, notice: success("updated")
      journal "User", "update", @user.id
    else
      failure @user
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    redirect_to users_path, alert: success("deleted")
    journal "User", "destroy", @user.id
  end

  private

  def resource_params
    params.require(:user).permit(:handle, :password, :first_name, :last_name, :otp_required, roles: [])
  end

  def success(action)
    t("thing.#{action}", thing: t("user.thing", handle: @user.handle))
  end
end
