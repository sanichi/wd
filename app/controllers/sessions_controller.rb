class SessionsController < ApplicationController
  def new
    skip_sign_in
  end

  def create
    user = User.find_by(handle: params[:handle])
    user = user&.authenticate(params[:password]) unless current_user.admin?
    if user
      session[:user_id] = user.id
      redirect_to home_path, notice: t("session.success", name: user.first_name)
    else
      flash.now[:alert] = t("session.invalid")
      skip_sign_in
      render :new
    end
  end

  def destroy
    name = current_user.first_name
    session[:user_id] = nil
    redirect_to home_path, notice: t("session.goodbye", name: name)
  end

  private

  def skip_sign_in
    @skip_sign_in = true
  end
end
