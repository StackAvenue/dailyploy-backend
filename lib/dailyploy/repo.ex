defmodule Dailyploy.Repo do
  use Ecto.Repo,
    otp_app: :dailyploy,
    adapter: Ecto.Adapters.Postgres
end
