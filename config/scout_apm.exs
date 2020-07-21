use Mix.Config

config :scout_apm,
  # The app name that will appear within the Scout UI
  name: {:system, "SCOUT_APP_NAME"},
  key: {:system, "SCOUT_APP_KEY"}
