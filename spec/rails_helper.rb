# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)

# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc.
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
Dir[Rails.root.join('spec', 'support', '**', '*.rb')].each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

RSpec.configure do |config|
  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")
end

Capybara.configure do |config|
  # Exact matches.
  config.exact = true
end

def login(user)
  visit home_path
  click_link t("session.sign_in")
  fill_in t("user.handle"), with: user.handle
  fill_in t("user.password"), with: user.password
  click_button t("session.sign_in")
end

def otp_attempt
  ROTP::TOTP.new(User::OTP_TEST_SECRET, issuer: User::OTP_ISSUER).now
end

def t(key, **opts)
  I18n.t(key, **opts)
end

def expect_error(page, text)
  expect(page).to have_css("div.rails-alert", text: text)
end

def expect_notice(page, text)
  expect(page).to have_css("div.notice", text: text)
end

def files
  Rails.root + "spec" + "files"
end

def pgn_files
  files + "pgn"
end

def pgn_file(name)
  (pgn_files + name).read
end

def random_pgn_file
  pgn_files.glob("*.pgn").sample.read
end

def all_pgn_files
  pgn_files.glob("*.pgn").map { |p| p.read }
end
