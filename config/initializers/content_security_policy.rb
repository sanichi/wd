# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy
# For further information see the following documentation
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.base_uri        :self
    policy.default_src     :none
    policy.img_src         :self
    policy.script_src      :self
    policy.style_src       :self, :unsafe_inline # redcarpet
    policy.frame_ancestors :none
    policy.form_action     :self
  end
  config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
  config.content_security_policy_nonce_directives = %w(script-src)
end
