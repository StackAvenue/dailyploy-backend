defmodule Dailyploy.Auth.Pipeline do
  use Guardian.Plug.Pipeline, otp_app: :Dailyploy,
  module: Dailyploy.Auth.Guardian,
  error_handler: Dailyploy.Auth.ErrorHandler

  plug Guardian.Plug.VerifyHeader, realm: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
