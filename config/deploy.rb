set :use_sudo, false
set :user, 'wallpapers'

set :deploy_to, '/home/wallpapers/www/'
set :application, 'wallpapers'
set :repository,  'git@github.com:alexandrebini/wallpapers.git'
set :branch,  'master'
set :scm, :git
set :deploy_via, :remote_cache
set :keep_releases, 5

role :web,  'wallpapers'
role :app, 'wallpapers'
role :db,  'wallpapers', primary: true
set :rails_env, 'production'

# rvm
set :rvm_ruby_string, 'ruby-1.9.3-p362@wallpapers'
set :rvm_type, :system
require 'rvm/capistrano'

# ==========================================================
before 'deploy:assets:precompile', 'assets:bundle'
after 'deploy', 'deploy:restart', 'deploy:cleanup'

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, roles: :app do
    run "#{ try_sudo } touch #{ File.join(current_path, 'tmp', 'restart.txt') }"
  end
end

namespace :assets do
  task :bundle, roles: :app do
    run "cd #{ release_path } && bundle install"
  end

  desc 'build missing paperclip styles'
  task :build_missing_paperclip_styles, roles: :app do
    run "cd #{ release_path }; RAILS_ENV=#{ rails_env } bundle exec rake paperclip:refresh:missing_styles"
  end
end