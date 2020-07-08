set :application, "wd"
set :repo_url, "git@bitbucket.org:sanichi/wd.git"
append :linked_files, "config/database.yml", "config/master.key"
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"
set :log_level, :info

# set :default_env, { path: "/opt/ruby/bin:$PATH" }
# set :local_user, -> { `git config user.name`.chomp }
# set :keep_releases, 5
