class ApplicationController < ActionController::Base
  before_action :remember_last_guest_path

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.html { redirect_to signin_path, alert: exception.message }
      format.json { head :forbidden, content_type: "text/html" }
      format.js   { head :forbidden, content_type: "text/html" }
    end
  end

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) || Guest.new
  end

  helper_method :current_user

  def remember_last_guest_path
    return unless request.request_method == "GET"
    return unless current_user.guest?
    return if request.fullpath == signin_path
    session[:last_guest_path] = request.fullpath
  end

  def failure(object)
    flash.now[:alert] = object.errors.full_messages.join(", ")
  end
end
