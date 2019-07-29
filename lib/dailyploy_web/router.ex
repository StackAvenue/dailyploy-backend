defmodule DailyployWeb.Router do
  use DailyployWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api/v1", DailyployWeb do
    pipe_through :api

    post "/sign_up", UserController, :create
    post "/sign_in", UserController, :sign_in

    resources "/projects", ProjectController do
      resources "/tasks", TaskController
    end

    resources "/workspaces", WorkspaceController do
      resources "/tags", TagController, only: [:create, :update, :delete, :index, :show]
    end
  end
end
