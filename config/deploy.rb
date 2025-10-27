# config valid for current version and patch releases of Capistrano
lock "~> 3.18.0"

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
append :linked_files, "config/database.yml", "config/master.key", ".env"

# Default value for linked_dirs is []
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets",
       "vendor/bundle", ".bundle", "public/system", "public/uploads",
       "storage", "tmp/thruster"

# Default value for default_env is {}
set :default_env, { path: "/usr/local/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 5

# Rbenv configuration
set :rbenv_type, :user
set :rbenv_ruby, File.read(".ruby-version").strip
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w[rake gem bundle ruby rails thruster]
set :rbenv_roles, :all

# Thruster configuration
set :thruster_roles, :web
set :thruster_env_vars, {
  RAILS_ENV: "production",
  SECRET_KEY_BASE: -> { ENV["SECRET_KEY_BASE"] }
}

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
      before "deploy:restart", "thruster:start"
      invoke "deploy"
    end
  end

  desc "Restart application"
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      invoke "thruster:restart"
    end
  end

  desc "Stop application"
  task :stop do
    on roles(:app) do
      invoke "thruster:stop"
    end
  end

  before :starting,     :check_revision
  after  :finishing,    :compile_assets
  after  :finishing,    :cleanup
  after  :finishing,    :restart
end

# Thruster-specific tasks
namespace :thruster do
  desc "Check Thruster status"
  task :status do
    on roles(:web) do
      within current_path do
        execute :bundle, :exec, :thruster, :status
      end
    end
  end

  desc "Show Thruster logs"
  task :logs do
    on roles(:web) do
      within current_path do
        execute :tail, "-f", "#{shared_path}/log/thruster.log"
      end
    end
  end
end
