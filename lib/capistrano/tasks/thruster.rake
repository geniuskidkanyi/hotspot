# Capistrano tasks for Thruster management
# Author: Muhammed Kanyi (@geniuskidkanyi)

namespace :thruster do
  desc "Setup Thruster directories"
  task :setup do
    on roles(:web) do
      execute :mkdir, "-p", "#{shared_path}/tmp/thruster/cache"
      execute :mkdir, "-p", "#{shared_path}/tmp/thruster/certificates"
      execute :mkdir, "-p", "#{shared_path}/log"
    end
  end

  desc "Upload Thruster systemd service file"
  task :upload_service do
    on roles(:web) do
      service_file = <<~SERVICE
        [Unit]
        Description=Thruster HTTP/2 Proxy for Rails
        After=network.target rails-puma.service
        Requires=rails-puma.service

        [Service]
        Type=simple
        User=deploy
        Group=deploy
        WorkingDirectory=#{current_path}

        Environment=RAILS_ENV=production
        EnvironmentFile=#{shared_path}/.env

        AmbientCapabilities=CAP_NET_BIND_SERVICE

        ExecStart=/home/deploy/.rbenv/shims/bundle exec thruster /var/www/#{fetch(:application)}/current/bin/rails server

        ExecReload=/bin/kill -HUP $MAINPID
        ExecStop=/bin/kill -TERM $MAINPID

        Restart=always
        RestartSec=5
        SyslogIdentifier=thruster

        StandardOutput=append:#{shared_path}/log/thruster.stdout.log
        StandardError=append:#{shared_path}/log/thruster.stderr.log

        NoNewPrivileges=false
        PrivateTmp=true
        LimitNOFILE=65536

        CapabilityBoundingSet=CAP_NET_BIND_SERVICE

        [Install]
        WantedBy=multi-user.target
      SERVICE

      upload! StringIO.new(service_file), "/tmp/rails-thruster.service"
      execute :sudo, :mv, "/tmp/rails-thruster.service", "/etc/systemd/system/rails-thruster.service"
      execute :sudo, :systemctl, "daemon-reload"
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
    rescue SSHKit::Command::Failed
      warn "Thruster service is not running"
    end
  end

  desc "Restart Thruster"
  task :restart do
    on roles(:web) do
      if test("[ -f /etc/systemd/system/rails-thruster.service ]")
        execute :sudo, :systemctl, :restart, "rails-thruster"
      else
        invoke "thruster:upload_service"
        invoke "thruster:enable"
        invoke "thruster:start"
      end
    end
  end

  desc "Reload Thruster configuration"
  task :reload do
    on roles(:web) do
      execute :sudo, :systemctl, :reload, "rails-thruster"
    rescue SSHKit::Command::Failed
      warn "Failed to reload Thruster, trying restart instead"
      invoke "thruster:restart"
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
      execute :sudo, :journalctl, "-u", "rails-thruster", "-f", "--lines=100"
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

  before "thruster:start", "thruster:setup"
  before "thruster:start", "thruster:upload_service"
end
