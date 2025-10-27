# Capistrano tasks for Thruster management

namespace :thruster do
  desc "Install Thruster gem"
  task :install do
    on roles(:web) do
      within release_path do
        execute :bundle, :exec, :gem, :install, :thruster
      end
    end
  end

  desc "Start Thruster"
  task :start do
    on roles(:web) do
      execute :sudo, :systemctl, :start, "rails-thruster"
    end
  end

  desc "Stop Thruster"
  task :stop do
    on roles(:web) do
      execute :sudo, :systemctl, :stop, "rails-thruster"
    end
  end

  desc "Restart Thruster"
  task :restart do
    on roles(:web) do
      execute :sudo, :systemctl, :restart, "rails-thruster"
    end
  end

  desc "Reload Thruster configuration"
  task :reload do
    on roles(:web) do
      execute :sudo, :systemctl, :reload, "rails-thruster"
    end
  end

  desc "Check Thruster status"
  task :status do
    on roles(:web) do
      execute :sudo, :systemctl, :status, "rails-thruster"
    end
  end

  desc "Show Thruster logs"
  task :logs do
    on roles(:web) do
      execute :sudo, :journalctl, "-u", "rails-thruster", "-f"
    end
  end

  desc "Enable Thruster service"
  task :enable do
    on roles(:web) do
      execute :sudo, :systemctl, :enable, "rails-thruster"
    end
  end

  desc "Disable Thruster service"
  task :disable do
    on roles(:web) do
      execute :sudo, :systemctl, :disable, "rails-thruster"
    end
  end

  desc "Setup Thruster cache directories"
  task :setup_cache do
    on roles(:web) do
      execute :mkdir, "-p", "#{shared_path}/tmp/thruster/cache"
      execute :mkdir, "-p", "#{shared_path}/tmp/thruster/certificates"
    end
  end

  before "thruster:start", "thruster:setup_cache"
end

namespace :puma do
  desc "Start Puma"
  task :start do
    on roles(:app) do
      execute :sudo, :systemctl, :start, "rails-puma"
    end
  end

  desc "Stop Puma"
  task :stop do
    on roles(:app) do
      execute :sudo, :systemctl, :stop, "rails-puma"
    end
  end

  desc "Restart Puma"
  task :restart do
    on roles(:app) do
      execute :sudo, :systemctl, :restart, "rails-puma"
    end
  end

  desc "Check Puma status"
  task :status do
    on roles(:app) do
      execute :sudo, :systemctl, :status, "rails-puma"
    end
  end

  desc "Show Puma logs"
  task :logs do
    on roles(:app) do
      execute :sudo, :journalctl, "-u", "rails-puma", "-f"
    end
  end

  desc "Enable Puma service"
  task :enable do
    on roles(:app) do
      execute :sudo, :systemctl, :enable, "rails-puma"
    end
  end
end
