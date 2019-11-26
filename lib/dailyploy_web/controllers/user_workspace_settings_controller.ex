defmodule DailyployWeb.UserWorkspaceSettingsController do
  use DailyployWeb, :controller
  import Plug.Conn
  # alias Dailyploy.Schema.WorkspaceS
  alias Dailyploy.Schema.Role
  # alias Dailyploy.Schema.DailyStatusMailSetting
  alias Dailyploy.Schema.UserWorkspaceSetting
  # alias Dailyploy.Model.User, as: UserModel
  # alias Dailyploy.Model.Workspace, as: WorkspaceModel
  alias Dailyploy.Model.UserWorkspaceSetting, as: UserWorkspaceSettingsModel
  alias Dailyploy.Model.AdminshipRemoval, as: AdminshipRemovalModel
  # alias Dailyploy.Model.UserWorkspace, as: UserWorkspaceModel
  alias Dailyploy.Model.Role, as: RoleModel
  alias Dailyploy.Model.DailyStatusMailSetting, as: DailyStatusMailSettingsModel

  plug Auth.Pipeline

  action_fallback DailyployWeb.FallbackController

  def update(conn, _) do
    {:ok, params} = Map.fetch(conn, :params)

    case UserWorkspaceSettingsModel.update(params) do
      :error -> send_resp(conn, 401, "UNAUTHORIZED")
      workspace -> render(conn, "show.json", workspace: workspace)
    end
  end

  # remove workspace admin
  def remove_workspace_admin(conn, user_params) do
    %{"user_id" => user_id, "workspace_id" => workspace_id} = user_params
    %Role{id: role_id} = RoleModel.get_role_by_name!("member")
    # role id extract
    user_workspace_attributes = %{
      "user_id" => user_id,
      "workspace_id" => workspace_id,
      "role_id" => role_id
    }

    case AdminshipRemovalModel.remove_from_adminship(user_workspace_attributes) do
      :error -> send_resp(conn, 401, "UNAUTHORIZED")
      {:ok, workspace} -> render(conn, "show.json", workspace: workspace)
    end
  end

  def add_workspace_admin(conn, user_params) do
    %{"user_id" => user_id, "workspace_id" => workspace_id} = user_params
    %Role{id: role_id} = RoleModel.get_role_by_name!("admin")
    # role id extract
    user_workspace_attributes = %{
      "user_id" => user_id,
      "workspace_id" => workspace_id,
      "role_id" => role_id
    }

    case AdminshipRemovalModel.add_for_adminship(user_workspace_attributes) do
      :error -> send_resp(conn, 401, "UNAUTHORIZED")
      {:ok, workspace} -> render(conn, "show.json", workspace: workspace)
    end
  end

  def daily_status_mail_settings(conn, user_params) do
    case user_params["is_active"] do
      true ->
        %{"workspace_id" => workspace_id} = user_params

        %UserWorkspaceSetting{id: id} =
          UserWorkspaceSettingsModel.get_user_workspace_settings_id(workspace_id)

        params =
          user_params
          |> Map.new(fn {key, value} -> {String.to_atom(key), value} end)
          # changes 
          |> Map.put_new(:user_workspace_setting_id, id)

        case DailyStatusMailSettingsModel.create_daily_status_mail_settings(params) do
          {:error, status} ->
            conn
            |> put_status(422)
            |> render("changeset_error.json", %{errors: status.errors})

          {:ok, status} ->
            render(conn, "index.json", status)
        end

      false ->
        case DailyStatusMailSettingsModel.stop_and_resume(user_params) do
          {:error, _} -> send_resp(conn, 401, "UNAUTHORIZED")
          {:ok, params} -> render(conn, "index.json", params)
        end
    end
  end
end
