class ApplicationController < ActionController::Base
  rescue_from CanCan::AccessDenied do |exception|
    session[:intended_path] = request.fullpath
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

  def failure(object)
    flash.now[:alert] = object.errors.full_messages.join(", ")
  end

  helper_method :current_user
end
