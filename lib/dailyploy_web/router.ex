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
   get "/token_details/:token_id", TokenDetailsController, :index
   get "/roles", RoleController, :index
   resources "/task_category", TaskCategoryController, only: [:create, :delete, :index, :show]
  end

  scope "/api/v1", DailyployWeb do
    pipe_through :jwt_authenticated

    get "/logged_in_user", UserController, :show
    resources "/users", UserController

    resources "/workspaces", WorkspaceController, only: [:index] do
      resources "/members", MemberController, only: [:index , :show, :update, :delete]
      resources "/tags", TagController, only: [:create, :update, :delete, :index, :show]
      resources "/workspace_settings", UserWorkspaceSettingsController, only: [:update]
      post "/workspace_settings/adminship_removal", UserWorkspaceSettingsController, :remove_workspace_admin
      post "/workspace_settings/add_admin", UserWorkspaceSettingsController, :add_workspace_admin
      post "/workspace_settings/daily_status_mail_settings", UserWorkspaceSettingsController, :daily_status_mail_settings
      resources "/reports", ReportController, only: [:index]

      resources "/projects", ProjectController do
        resources "/tasks", TaskController
      end
    end

    resources "/projects", ProjectController
    resources "/invitations", InvitationController
    get "/workspaces/:workspace_id/project_tasks", WorkspaceController, :project_tasks
    get "/workspaces/:workspace_id/user_tasks", WorkspaceController, :user_tasks
  end
end
