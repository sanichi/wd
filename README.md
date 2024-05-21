# README

This rails app is the [website](https://wanderingdragonschess.club/) of the Wandering Dragons Chess Club.

To run/test locally:

* Install the version of ruby in `.ruby-version`.
* Run `bin/bundle install`.
* Overwrite `config/credentials.yml.enc` (it only has a secret_key_base) with a new `config/master.key`.
* Make sure you have `postgres` running locally.
* Create the unversioned file `config/database.yml` something like this:
```
default: &default
  adapter: postgresql
  encoding: unicode
  pool: 5
  username: blah
  password: blah
development:
  <<: *default
  database: wd_development
test:
  <<: *default
  database: wd_test
```
* Run `bin/rails db:create`.
* Sync the development database with the production database if you can.
* If you can't sync then at least create one admin user with `bin/rails c`:
```
User.create!(first_name: "Blah", last_name: "Blah", handle: "BB", roles: ["admin"], password: "blah")
```
* Run the app locally on port 3000 with `bin/rails s`.
* Test by running `bin/rake`.
