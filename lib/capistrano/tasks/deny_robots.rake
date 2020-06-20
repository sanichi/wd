# Use like this in a config/deploy/*.rb file:
#
# namespace :deploy do
#   before :restart, :deny_robots
# end
#
namespace :deploy do
  task :deny_robots do
    on roles(:app) do |host|
      within release_path do
        execute :sed, "-i", "'s/Allow/Disallow/'", "public/robots.txt"
        execute :grep, "Disallow", "public/robots.txt"
      end
    end
  end
end
