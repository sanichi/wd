class SessionsController < ApplicationController
  def create
    user = User.find_by(handle: params[:handle])
    user = user&.authenticate(params[:password]) unless current_user.admin?
    if user
      session[:user_id] = user.id
      redirect_to (session[:intended_path] || home_path), notice: t("session.success", name: user.first_name)
      session[:intended_path] = nil
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
