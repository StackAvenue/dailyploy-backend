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
  end

  scope "/api/v1", DailyployWeb do

    post "/sign_up", UserController, :create
    post "/sign_in", UserController, :sign_in

    resources "/workspaces", WorkspaceController do
      resources "/tags", TagController, only: [:create, :update, :delete, :index, :show]
        resources "/projects", ProjectController do
          resources "/tasks", TaskController
      end
    end
  end
end
