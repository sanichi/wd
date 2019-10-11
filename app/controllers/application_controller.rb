class ApplicationController < ActionController::Base
  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) || Guest.new
  end

  private

  def skip_sign_in?
    !!@skip_sign_in
  end

  helper_method :current_user, :skip_sign_in?
end
