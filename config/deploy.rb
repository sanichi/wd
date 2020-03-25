# config valid for specified versions of Capistrano
# lock "~> 3.11.2"

set :application, "sni_wd_app"
set :repo_url, "git@bitbucket.org:sanichi/sni_wd_app.git"
set :deploy_to, "/var/www/wd"
append :linked_files, "config/database.yml", "config/master.key", "public/sitemap.xml"
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"
set :log_level, :info

# set :default_env, { path: "/opt/ruby/bin:$PATH" }
# set :local_user, -> { `git config user.name`.chomp }
# set :keep_releases, 5
