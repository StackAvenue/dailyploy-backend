defmodule DailyployWeb.MemberController do
  use DailyployWeb, :controller
  alias Dailyploy.Model.UserWorkspace, as: UserWorkspaceModel
  alias Dailyploy.Model.UserWorkspaceSettings, as: UserWorkspaceSettingsModel

  alias Dailyploy.Model.User, as: UserModel
  alias Dailyploy.Repo

  plug Auth.Pipeline

  action_fallback DailyployWeb.FallbackController

  def index(conn, %{"workspace_id" => workspace_id}) do
    members = UserModel.list_users(workspace_id) |> Repo.preload([:projects])

    render(conn, "index_with_projects.json", members: members)
  end

  def update(conn, %{"id" => user_id, "role_id" => role_id, "working_hours" => working_hours, "workspace_id" => workspace_id} = attrs) do
    user_workspace = UserWorkspaceModel.get_user_workspace!(%{user_id: user_id, workspace_id: workspace_id})
    case UserWorkspaceModel.update_user_workspace(user_workspace, %{user_id: user_id, workspace_id: workspace_id, role_id: role_id}) do
      {:ok, _} -> 
        user_workspace_settings = UserWorkspaceSettingsModel.get_user_workspace_settings!(%{user_id: user_id, workspace_id: workspace_id})
        case UserWorkspaceSettingsModel.update_user_workspace_settings(user_workspace_settings, %{user_id: user_id, workspace_id: workspace_id, working_hours: working_hours}) do
          {:ok, _} -> conn |> json(%{"user_id" => user_id, "role_id" => role_id, "working_hours" => working_hours, "workspace_id" => workspace_id})
          {:error, _} ->  send_resp(conn, 404, "Not Found")   
        end
        
      {:error, _} ->  send_resp(conn, 404, "Not Found") 
    end
   end

   def delete(conn, %{"id" => user_id, "workspace_id" => workspace_id} = attrs) do
    user_workspace = UserWorkspaceModel.get_user_workspace!(%{user_id: user_id, workspace_id: workspace_id})
    user_workspace_settings = UserWorkspaceSettingsModel.get_user_workspace_settings!(%{user_id: user_id, workspace_id: workspace_id})
    case UserWorkspaceModel.delete_user_workspace(user_workspace) do
      {:ok, _} -> 
        case UserWorkspaceSettingsModel.delete_user_workspace_settings(user_workspace_settings) do
          {:ok, _} -> send_resp(conn, :no_content, "User Successfully deleted from Workspace")
          {:error, _} ->  send_resp(conn, 404, "Not Found")   
        end
      {:error, _} ->  send_resp(conn, 404, "Not Found") 
    end
   end
end
