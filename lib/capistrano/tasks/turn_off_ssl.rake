namespace :deploy do
  task :turn_off_ssl do
    on roles(:app) do |host|
      within release_path do
        execute :sed, "-i", "'s/force_ssl = true/force_ssl = false/'", "config/environments/production.rb"
        execute :grep, "force_ssl", "config/environments/production.rb"
      end
    end
  end
end
