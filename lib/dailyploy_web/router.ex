defmodule DailyployWeb.Router do
  use DailyployWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :jwt_authenticated do
    plug Auth.Pipeline
  end

  scope "/api/v1", DailyployWeb do
    post "/sign_up", SessionController, :sign_up
    post "/sign_in", SessionController, :sign_in
  end

  scope "/api/v1", DailyployWeb do
    pipe_through :jwt_authenticated

    resources "/workspaces", WorkspaceController, only: [:index] do
      resources "/members", UserController, only: [:index, :show]
      resources "/tags", TagController, only: [:create, :update, :delete, :index, :show]

      resources "/projects", ProjectController do
        resources "/tasks", TaskController
      end
    end

    get "/workspaces/:workspace_id/project_tasks", WorkspaceController, :project_tasks
    get "/workspaces/:workspace_id/user_tasks", WorkspaceController, :user_tasks
  end
end
