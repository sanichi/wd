source 'https://rubygems.org'

gem 'rails', '8.1.1'
gem 'haml-rails', '< 4.0'
gem 'jquery-rails', '~> 4.3'
gem 'sassc-rails', '~> 2.1'
gem 'bootstrap', '~> 5.0'
gem 'pg', '>= 0.18', '< 2.0'
gem 'bcrypt', '~> 3.1.7'
gem 'cancancan', '~> 3.0'
gem 'meta-tags', '~> 2.12'
gem 'redcarpet', '~> 3.5'
gem 'jbuilder', '~> 2.7'
gem 'pgn', git: 'https://github.com/sanichi/pgn'
gem 'rotp', '~> 6.2'
gem 'rqrcode', '~> 3.1'
gem 'sprockets-rails', '~> 3.4'
gem 'importmap-rails', '~> 2.1'
gem 'turbo-rails', '~> 2.0'
gem 'sni', git: 'https://github.com/sanichi/sni'
gem 'mechanize', '~> 2.10'

group :development, :test do
  gem 'rspec-rails', '< 9'
  gem 'capybara', '< 4'
  gem 'byebug', platforms: :mri
  gem 'launchy', '< 4'
  gem 'factory_bot_rails', '< 7'
  gem 'faker', '< 4'
  gem "selenium-webdriver", "~> 4.28"
end

group :test do
  gem 'database_cleaner-active_record', '~> 2.0'
end

group :development do
  gem 'puma', '< 8'
  gem 'capistrano-rails', '~> 1.4', require: false
  gem 'capistrano-passenger', '~> 0.2', require: false
  gem 'listen', '~> 3.2'
  gem 'awesome_print', '~> 1.9', require: false
end

gem "stimulus-rails", "~> 1.3"
