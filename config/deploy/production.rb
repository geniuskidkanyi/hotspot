# Production deployment configuration
server "app.root.gm",
  user: "deploy",
  roles: %w[web app db]
