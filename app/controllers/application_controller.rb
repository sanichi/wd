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

  def journal(resource, action, resource_id=nil, handle: nil)
    handle = current_user.handle if handle.nil?
    Journal.create(handle: handle, remote_ip: request.remote_ip, resource: resource, resource_id: resource_id, action: action)
  end

  # load_and_authorize_resource will not set the user_id if user can manage all
  # see https://github.com/CanCanCommunity/cancancan/wiki/Controller-Authorization-Example
  def assign_to_admin_if_no_user(object)
    if object.user_id.blank? && current_user.admin?
      object.user_id = current_user.id
    end
  end
end
