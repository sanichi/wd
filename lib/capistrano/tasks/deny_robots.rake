namespace :deploy do
  task :deny_robots do
    on roles(:app) do |host|
      within release_path do
        execute :sed, "-i", "'s/Allow/Deny/'", "public/robots.txt"
        execute :grep, "Deny", "public/robots.txt"
      end
    end
  end
end
