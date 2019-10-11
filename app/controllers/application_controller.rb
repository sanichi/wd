class ApplicationController < ActionController::Base
  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) || Guest.new
  end

  helper_method :current_user
end
