# Production deployment configuration
server "app.root.gm",
  user: "deploy",
  roles: %w[web app db]

# Server-specific settings
set :rails_env, "production"

# Thruster configuration for production
set :thruster_config, {
  port: 443,
  http_port: 80,
  target: "http://127.0.0.1:3000",
  cache_size: "64m",
  max_cache_item_size: "1m",
  storage: "#{shared_path}/tmp/thruster/cache"
}
