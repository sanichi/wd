source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.2'

gem 'rails', '~> 6.0.0'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 3.11'
gem 'haml-rails', '~> 2.0'
gem 'sassc-rails', '~> 2.1'
gem 'jbuilder', '~> 2.7'
gem 'uglifier', '~> 4.2'
gem 'jquery-rails', '~> 4.3'
gem 'meta-tags', '~> 2.12'
gem "redcarpet", "~> 3.5"
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails', '~> 3.8'
  gem 'factory_bot_rails', '~> 5.0'
  gem 'faker', '~> 2.1'
end

group :test do
  gem 'database_cleaner'
end

group :development do
  gem 'capistrano-rails', '~> 1.4', require: false
  gem 'capistrano-passenger', '~> 0.2', require: false
  gem 'awesome_print', require: "ap"
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end
