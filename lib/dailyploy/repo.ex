defmodule Dailyploy.Repo do
  use Ecto.Repo,
    otp_app: :dailyploy,
    adapter: Ecto.Adapters.Postgres

  use Scrivener, page_size: 1000
end
