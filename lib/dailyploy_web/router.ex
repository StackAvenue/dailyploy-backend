defmodule DailyployWeb.Router do
  use DailyployWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :jwt_authenticated do
    plug Auth.Pipeline
  end

  scope "/api/v1", DailyployWeb do
    pipe_through :jwt_authenticated

    get "/user", UserController, :show
    resources "/users", UserController, only: [:index]
  end

  scope "/api/v1", DailyployWeb do
    post "/sign_up", SessionController, :sign_up
    post "/sign_in", SessionController, :sign_in

    resources "/workspaces", WorkspaceController, only: [:index] do
      resources "/tags", TagController, only: [:create, :update, :delete, :index, :show]

      resources "/projects", ProjectController do
        resources "/tasks", TaskController
      end
    end
  end
end
