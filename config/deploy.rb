# config valid for current version and patch releases of Capistrano
lock "~> 3.19.2"

set :application, "my_rails_app"
set :repo_url, "git@github.com:geniuskidkanyi/hotspot.git"

# Default branch is :master
set :branch, ENV["BRANCH"] || "main"

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/var/www/#{fetch(:application)}"

# Default value for :format is :airbrussh
set :format, :airbrussh

# You can configure the Airbrussh format using :format_options
set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
set :pty, true

# Default value for :linked_files is []
append :linked_files, ".env", "config/master.key"

# Default value for linked_dirs is []
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets",
       "vendor/bundle", ".bundle", "public/system", "public/uploads",
       "storage", "tmp/thruster"

# Default value for default_env is {}
set :default_env, { path: "/usr/local/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 5

# Rbenv configuration

namespace :deploy do
  desc "Make sure local git is in sync with remote."
  task :check_revision do
    on roles(:app) do
      unless `git rev-parse HEAD` == `git rev-parse origin/#{fetch(:branch)}`
        puts "WARNING: HEAD is not the same as origin/#{fetch(:branch)}"
        puts "Run `git push` to sync changes."
        exit
      end
    end
  end

  desc "Initial Deploy"
  task :initial do
    on roles(:app) do
      invoke "deploy"
      invoke "puma:enable"
      invoke "thruster:enable"
      invoke "puma:start"
      invoke "thruster:start"
    end
  end

  desc "Restart application"
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      invoke "puma:restart"
      invoke "thruster:restart"
    end
  end

  desc "Stop application"
  task :stop do
    on roles(:app) do
      invoke "thruster:stop"
      invoke "puma:stop"
    end
  end

  before :starting,     :check_revision
  after  :finishing,    :compile_assets
  after  :finishing,    :cleanup
  after  :finishing,    :restart
end
