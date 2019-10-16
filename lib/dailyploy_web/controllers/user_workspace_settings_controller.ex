defmodule DailyployWeb.UserWorkspaceSettingsController do
  use DailyployWeb, :controller
  import Plug.Conn
  alias Dailyploy.Schema.Workspace
  alias Dailyploy.Schema.Role
  alias Dailyploy.Schema.DailyStatusMailSettings
  alias Dailyploy.Schema.UserWorkspaceSettings
  alias Dailyploy.Model.User, as: UserModel
  alias Dailyploy.Model.Workspace, as: WorkspaceModel
  alias Dailyploy.Model.UserWorkspaceSettings, as: UserWorkspaceSettingsModel  
  alias Dailyploy.Model.AdminshipRemoval, as: AdminshipRemovalModel
  alias Dailyploy.Model.UserWorkspace, as: UserWorkspaceModel
  alias Dailyploy.Model.Role, as: RoleModel
  alias Dailyploy.Model.DailyStatusMailSettings, as: DailyStatusMailSettingsModel

  plug Auth.Pipeline

  action_fallback DailyployWeb.FallbackController

  def update(conn, _) do
    {:ok, params} = Map.fetch(conn, :params)
      case UserWorkspaceSettingsModel.update(params) do
        :error -> send_resp(conn, 401, "UNAUTHORIZED")
        workspace -> render(conn, "show.json", workspace: workspace)
      end
  end

  def remove_workspace_admin(conn, user_params) do #remove workspace admin
    %{"user_id" => user_id, "workspace_id" => workspace_id} = user_params
    %Role{id: role_id} = RoleModel.get_role_by_name!("member")
    user_workspace_attributes = %{"user_id" => user_id, "workspace_id" => workspace_id, "role_id" => role_id} #role id extract
    case AdminshipRemovalModel.remove_from_adminship(user_workspace_attributes) do
        :error -> send_resp(conn, 401, "UNAUTHORIZED")
        {:ok, workspace } -> render(conn, "show.json", workspace: workspace)
    end
  end

  def add_workspace_admin(conn, user_params) do
    %{"user_id" => user_id, "workspace_id" => workspace_id} = user_params
    %Role{id: role_id} = RoleModel.get_role_by_name!("admin")
    user_workspace_attributes = %{"user_id" => user_id, "workspace_id" => workspace_id, "role_id" => role_id} #role id extract
    case AdminshipRemovalModel.add_for_adminship(user_workspace_attributes) do
        :error -> send_resp(conn, 401, "UNAUTHORIZED")
        {:ok, workspace } -> render(conn, "show.json", workspace: workspace)
    end
  end

  def daily_status_mail_settings(conn, user_params) do
     case user_params["is_active"] do
      true -> 
        %{"workspace_id" => workspace_id, "bcc_mails" => bcc_mails, "cc_mails" => cc_mails, "to_mails" => to_mails, "is_active" => is_active, "email_text" => email_text} = user_params  
        %UserWorkspaceSettings{ id: id } = UserWorkspaceSettingsModel.get_user_workspace_settings_id(workspace_id)
        params = 
         user_params
          |> Map.new(fn {key,value} -> {String.to_atom(key),value} end)
          |> Map.put_new(:user_workspace_setting_id, id) #changes 
        case DailyStatusMailSettingsModel.create_daily_status_mail_settings(params) do
          {:error, status} ->
            conn
              |> put_status(422)
              |> render("changeset_error.json", %{errors: status.errors})
          {:ok, status} -> render(conn,"index.json", status)
        end
        
      false ->
         case DailyStatusMailSettingsModel.stop_and_resume(user_params) do
           {:error, _} -> send_resp(conn, 401, "UNAUTHORIZED")
           {:ok, params} -> render(conn,"index.json", params)
         end
          
      end 
  end

end
