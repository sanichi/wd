# Expiry is now handled by a date set in the session cookie value. See:
#   current_user in application_controller.rb
#   create in sessions_controller.rb
#   create in otp_secrets_controller.rb
Rails.application.config.session_store :cookie_store,
  key: "_wd_app_session",
  expire_after: 10.years
