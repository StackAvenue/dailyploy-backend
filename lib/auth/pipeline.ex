defmodule Auth.Pipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :dailyploy,
    module: Auth.Guardian,
    error_handler: Auth.ErrorHandler

  plug Guardian.Plug.VerifyHeader, realm: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource, allow_blank: true
end
