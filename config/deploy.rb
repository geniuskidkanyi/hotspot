# config valid for current version and patch releases of Capistrano
lock "~> 3.19.2"

set :application, "hotspot"
set :repo_url, "git@github.com:geniuskidkanyi/hotspot.git"

# Default branch is :master
set :branch, ENV["BRANCH"] || "main"

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/home/deploy/#{fetch :application}"

# Default value for :pty is false
set :pty, true

# Default value for :linked_files is []
# append :linked_files, ".env", "config/master.key"

# Default value for linked_dirs is []
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "vendor/bundle", ".bundle", "public/system", "public/uploads"

# Default value for keep_releases is 5
set :keep_releases, 5

# Rbenv configuration
