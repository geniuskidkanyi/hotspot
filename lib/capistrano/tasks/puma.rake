# Capistrano tasks for Puma management
# Author: Muhammed Kanyi (@geniuskidkanyi)

namespace :puma do
  desc "Setup Puma directories"
  task :setup do
    on roles(:app) do
      execute :mkdir, "-p", "#{shared_path}/tmp/pids"
      execute :mkdir, "-p", "#{shared_path}/tmp/sockets"
      execute :mkdir, "-p", "#{shared_path}/log"
    end
  end

  desc "Upload Puma systemd service file"
  task :upload_service do
    on roles(:app) do
      service_file = <<~SERVICE
        [Unit]
        Description=Puma HTTP Server for Rails (production)
        After=network.target

        [Service]
        Type=notify
        User=deploy
        Group=deploy
        WorkingDirectory=#{current_path}

        Environment=RAILS_ENV=production
        Environment=RACK_ENV=production
        EnvironmentFile=#{shared_path}/.env

        ExecStart=/home/deploy/.rbenv/shims/bundle exec puma -C #{current_path}/config/puma.rb
        ExecReload=/bin/kill -USR1 $MAINPID
        ExecStop=/bin/kill -TERM $MAINPID

        Restart=always
        RestartSec=10
        SyslogIdentifier=puma

        StandardOutput=append:#{shared_path}/log/puma.stdout.log
        StandardError=append:#{shared_path}/log/puma.stderr.log

        NoNewPrivileges=true
        PrivateTmp=true
        LimitNOFILE=65536

        [Install]
        WantedBy=multi-user.target
      SERVICE

      upload! StringIO.new(service_file), "/tmp/rails-puma.service"
      execute :sudo, :mv, "/tmp/rails-puma.service", "/etc/systemd/system/rails-puma.service"
      execute :sudo, :systemctl, "daemon-reload"
    end
  end

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
    rescue SSHKit::Command::Failed
      warn "Puma service is not running"
    end
  end

  desc "Restart Puma"
  task :restart do
    on roles(:app) do
      if test("[ -f /etc/systemd/system/rails-puma.service ]")
        execute :sudo, :systemctl, :restart, "rails-puma"
      else
        invoke "puma:upload_service"
        invoke "puma:enable"
        invoke "puma:start"
      end
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
      execute :sudo, :journalctl, "-u", "rails-puma", "-f", "--lines=100"
    end
  end

  desc "Enable Puma service"
  task :enable do
    on roles(:app) do
      execute :sudo, :systemctl, :enable, "rails-puma"
    end
  end

  desc "Disable Puma service"
  task :disable do
    on roles(:app) do
      execute :sudo, :systemctl, :disable, "rails-puma"
    end
  end

  before "puma:start", "puma:setup"
  before "puma:start", "puma:upload_service"
end
