class SessionsController < ApplicationController
  def create
    user = User.find_by(handle: params[:handle])&.authenticate(params[:password])
    if user
      session[:user_id] = user.id
      notice = t("session.success", name: user.first_name)
      role = t("user.roles.#{user.role}").downcase
      notice += " (#{role})" unless user.member?
      redirect_to home_path, notice: notice
    else
      flash.now[:alert] = t("session.invalid")
      render :new
    end
  end

  def destroy
    name = current_user.first_name
    session[:user_id] = nil
    redirect_to home_path, notice: t("session.goodbye", name: name)
  end
end
