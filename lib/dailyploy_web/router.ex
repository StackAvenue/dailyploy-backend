defmodule DailyployWeb.Router do
  use DailyployWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", DailyployWeb do
    pipe_through :api
  end
end
