defmodule DailyployWeb.UserWorkspaceSettings do
  use DailyployWeb, :controller
  import Plug.Conn
  alias Dailyploy.Schema.Workspace
  alias Dailyploy.Schema.Role
  alias Dailyploy.Model.User, as: UserModel
  alias Dailyploy.Model.Workspace, as: WorkspaceModel
  alias Dailyploy.Model.UserWorkspaceSettings, as: UserWorkspaceSettings  
  alias Dailyploy.Model.AdminshipRemoval, as: AdminshipRemovalModel
  alias Dailyploy.Model.UserWorkspace, as: UserWorkspaceModel
  alias Dailyploy.Model.Role, as: RoleModel

  plug Auth.Pipeline

  action_fallback DailyployWeb.FallbackController

  def update(conn, _) do
    {:ok, params} = Map.fetch(conn, :params)
      case UserWorkspaceSettings.update(params) do
        :error -> send_resp(conn, 401, "UNAUTHORIZED")
        workspace -> render(conn, "show.json", workspace: workspace)
      end
  end

  def adminship_removal(conn, user_params) do
    %{"user_workspace_settings_id" => user_id, "workspace_id" => workspace_id} = user_params
    %Role{id: role_id} = RoleModel.get_role_by_name!("member")
    user_workspace_attributes = %{"user_id" => user_id, "workspace_id" => workspace_id, "role_id" => role_id} #role id extract
    case AdminshipRemovalModel.remove_from_adminship(user_workspace_attributes) do
        :error -> send_resp(conn, 401, "UNAUTHORIZED")
        {:ok, workspace } -> render(conn, "show.json", workspace: workspace)
      end
  end


end
