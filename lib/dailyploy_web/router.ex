defmodule DailyployWeb.Router do
  use DailyployWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api/v1", DailyployWeb do
    pipe_through :api

    resources "/users", UserController, only: [:create, :show]
  end
end
