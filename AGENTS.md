# AGENTS.md - Rails Chess Club App

## Build/Test Commands
- `bin/rails s` - Start development server on port 3000
- `bin/rake` - Run full test suite (RSpec + Capybara)
- `bin/rspec spec/features/user_spec.rb` - Run single test file
- `bin/rails db:migrate` - Run database migrations
- `bin/rails c` - Rails console

## Code Style Guidelines
- **Ruby version**: Use version in `.ruby-version` (Ruby 3.x)
- **Naming**: snake_case for methods/vars, SCREAMING_SNAKE_CASE for constants
- **Classes**: PascalCase, inherit from ApplicationRecord/ApplicationController
- **Methods**: Use `def method_name =` for single-line methods
- **Validation**: Use Rails validators with custom messages
- **Dependencies**: PostgreSQL database, RSpec for testing, CanCanCan for authorization
- **Error handling**: Use `rescue_from` in controllers, flash messages for user feedback
- **Security**: Use `has_secure_password`, validate input formats with regex
- **Tests**: Feature tests with Capybara, factory_bot for test data
- **Imports**: Standard Rails requires, gems from Gemfile only

## Project Structure
Rails 8.0 app for Wandering Dragons Chess Club with users, games, blogs, and admin features.