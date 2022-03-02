# Be sure to restart your server when you modify this file.
Rails.application.config.session_store :cookie_store,
  key: "_wd_app_session",
  expire_after: 5.weeks # set to just a bit longer than User::Expires
