source 'https://rubygems.org'

gem 'rails', '6.0.3.2'
gem 'pg', '>= 0.18', '< 2.0'
gem 'haml-rails', '~> 2.0'
gem 'sassc-rails', '~> 2.1'
gem 'jbuilder', '~> 2.7'
gem 'uglifier', '~> 4.2'
gem 'jquery-rails', '~> 4.3'
gem 'meta-tags', '~> 2.12'
gem "redcarpet", '~> 3.5'
gem "bootstrap", '~> 4.3'
gem 'bcrypt', '~> 3.1.7'
gem 'cancancan', '~> 3.0'
gem 'actionview-encoded_mail_to', '~> 1.0'
gem 'pgn', '~> 0.3'
gem "mechanize", '~> 2.7', require: false
gem 'bootsnap', '>= 1.4.2', require: false # required in config/boot.rb

group :development, :test do
  gem 'byebug', platform: :mri
  gem 'rspec-rails', '~> 4.0'
  gem "capybara", "~> 3.28"
  gem 'factory_bot_rails', '~> 6.1'
  gem 'faker', '~> 2.1'
  gem 'launchy', '~> 2.4'
  gem 'awesome_print', require: "ap"
end

group :test do
  gem 'database_cleaner-active_record'
end

group :development do
  gem 'puma', '~> 4.3'
  gem 'capistrano-rails', '~> 1.4', require: false
  gem 'capistrano-passenger', '~> 0.2', require: false
  gem 'listen', '~> 3.2'
end
