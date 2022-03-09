# Expiry is now handled by a date set in the session cookie value. See:
#   current_user in application_controller.rb
#   create in sessions_controller.rb
#   create in otp_secrets_controller.rb
Rails.application.config.session_store :cookie_store,
  key: "#{Rails.env.production? ? '__Secure-' : '_'}Wd-Session",
  expire_after: 10.years
