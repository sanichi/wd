namespace :deploy do
  task :log do
    on roles(:app) do |_host|
      execute "kanshi.sh", fetch(:application)
    end
  end
end

after :'deploy:restart', :'deploy:log'
