set :stage, :staging
set :rails_env, :staging
server 'wallpapers', user: 'wallpapers', roles: %w{web app db}