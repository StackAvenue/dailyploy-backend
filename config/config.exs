# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :dailyploy,
  ecto_repos: [Dailyploy.Repo]

# Configures the endpoint
config :dailyploy, DailyployWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "R9RZUY1CYdX6IQ3r09F6BpFj5DP0ajxud28rAV/agN1UzbKDSyJXkS0HXW37JLwv",
  render_errors: [view: DailyployWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: Dailyploy.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# config quantum
config :dailyploy, Dailyploy.Helper.Scheduler,
  schedule: "50 23 * * *",
  overlap: false,
  timezone: "Asia/Calcutta",
  # global: true,
  jobs: [
    daily_status: [
      task: {Dailyploy.Helper.DailyStatus, :schedule_daily_status_mails, []}
    ]
    # {"17 19 * * *", {Dailyploy.Helper.DailyStatus, :schedule_daily_status_mails, []}}
    # {Dailyploy.Helper.DailyStatus, :schedule_daily_status_mails, []}
  ]

config :guardian, Auth.Guardian,
  issuer: "guardian",
  secret_key: "5iN7jguYnpqwt71+7R2kGMPNzdCJWWWknC+nrBXPyfWE8Jsw1lEWmTtZo1YisZ4A"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

config :arc,
  asset_host: "https://dailyploy-csv.s3.ap-south-1.amazonaws.com",
  storage: Arc.Storage.S3,
  bucket: System.get_env("AWS_S3_BUCKET"),
  virtual_host: true

# virtual_host: true

config :ex_aws,
  access_key_id: [System.get_env("AWS_ACCESS_KEY_ID"), :instance_role],
  secret_access_key: [System.get_env("AWS_SECRET_ACCESS_KEY"), :instance_role],
  region: "ap-south-1"

config :tesla, adapter: Tesla.Adapter.Hackney
