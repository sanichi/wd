class SessionsController < ApplicationController
  def create
    user = User.find_by(handle: params[:handle])
    user = user&.authenticate(params[:password]) unless current_user.admin?
    if user
      if user.otp_required?
        session[:otp_user_id] = user.id
        redirect_to new_otp_secret_path
      else
        session[:user_id] = user.id
        redirect_to (session[:last_guest_path] || root_path), notice: t("session.success", name: user.first_name)
        session[:last_guest_path] = nil
        journal "Session", "signin", handle: user.handle
      end
    else
      flash.now[:alert] = t("session.invalid")
      render :new
      journal "Session", "bounce", handle: params[:handle]
    end
  end

  def destroy
    redirect_to root_path, notice: t("session.goodbye", name: current_user.first_name)
    journal "Session", "signout", handle: current_user.handle
    session[:user_id] = nil
  end
end
