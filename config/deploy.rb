set :application, 'wallpapers'
set :repo_url, 'git@github.com:alexandrebini/wallpapers.git'

set :deploy_to, '/home/wallpapers/www'
set :scm, :git

set :format, :pretty
set :pty, true

set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# set :default_env, { path: "/opt/ruby/bin:$PATH" }
set :keep_releases, 5

namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
    end
  end

  after :finishing, 'deploy:cleanup'
end