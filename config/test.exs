use Mix.Config

# Configure your database
config :dailyploy, Dailyploy.Repo,
  username: System.get_env("POSTGRES_USER") || "postgres",
  password: System.get_env("POSTGRES_PASSWORD") || "postgres",
  database: System.get_env("POSTGRES_DB") || "dailyploy_test",
  hostname: System.get_env("POSTGRES_HOST") || "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :dailyploy, DailyployWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
