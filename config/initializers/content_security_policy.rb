# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy
# For further information see the following documentation
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy

# Header set Content-Security-Policy-Report-Only "default-src 'none'; form-action 'none'; frame-ancestors 'none'; report-uri https://{subdomain}.report-uri.com/r/d/csp/wizard"
Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src     :none
#   policy.font_src        :self, :https, :data
    policy.img_src         :self
#   policy.object_src      :none
    policy.script_src      :self
    policy.style_src       :self
    policy.form_action     :none
    policy.frame_ancestors :none
    policy.report_uri      "https://sanichi.report-uri.com/r/d/csp/wizard"
  end

  # Generate session nonces for permitted importmap and inline scripts
  config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
  config.content_security_policy_nonce_directives = %w(script-src)

  # Just report CSP violations to a specified URI. See:
  # https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy-Report-Only
  config.content_security_policy_report_only = true
end
