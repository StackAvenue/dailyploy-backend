defmodule DailyployWeb.UserWorkspaceSettingsController do
  use DailyployWeb, :controller
  import Plug.Conn
  # alias Dailyploy.Schema.WorkspaceS
  alias Dailyploy.Schema.Role
  # alias Dailyploy.Schema.DailyStatusMailSetting
  alias Dailyploy.Schema.UserWorkspaceSetting
  # alias Dailyploy.Model.User, as: UserModel
  alias Dailyploy.Model.Workspace, as: WorkspaceModel
  alias Dailyploy.Model.UserWorkspaceSetting, as: UserWorkspaceSettingsModel
  alias Dailyploy.Model.AdminshipRemoval, as: AdminshipRemovalModel
  # alias Dailyploy.Model.UserWorkspace, as: UserWorkspaceModel
  alias Dailyploy.Model.Role, as: RoleModel
  alias Dailyploy.Model.DailyStatusMailSetting, as: DailyStatusMailSettingsModel

  plug Auth.Pipeline
  plug :load_daily_status_mail when action in [:update_daily_status_mail, :show_daily_status_mail]
  plug :load_workspace when action in [:daily_status_mail_settings]
  action_fallback DailyployWeb.FallbackController

  def update(conn, _) do
    {:ok, params} = Map.fetch(conn, :params)

    case UserWorkspaceSettingsModel.update(params) do
      :error ->
        send_resp(conn, 401, "UNAUTHORIZED")

      workspace ->
        render(conn, "show.json", workspace: workspace)
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
      {:ok, workspace} -> render(conn, "show_something.json", workspace: workspace)
    end
  end

  def add_workspace_admin(conn, user_params) do
    %{"user_id" => user_id, "workspace_id" => workspace_id} = user_params
    %Role{id: role_id} = RoleModel.get_role_by_name!("admin")

    user_workspace_attributes = %{
      "user_id" => user_id,
      "workspace_id" => workspace_id,
      "role_id" => role_id
    }

    case AdminshipRemovalModel.add_for_adminship(user_workspace_attributes) do
      :error -> send_resp(conn, 401, "UNAUTHORIZED")
      {:ok, workspace} -> render(conn, "show_something.json", workspace: workspace)
    end
  end

  def daily_status_mail_settings(conn, user_params) do
    case conn.status do
      nil ->
        %{"workspace_id" => workspace_id} = user_params
        user = Guardian.Plug.current_resource(conn)

        params =
          user_params
          |> Map.new(fn {key, value} -> {String.to_atom(key), value} end)
          |> Map.put_new(:workspace_id, user_params["workspace_id"])
          |> Map.put_new(:user_id, user.id)

        case DailyStatusMailSettingsModel.create_daily_status_mail_settings(params) do
          {:error, status} ->
            conn
            |> put_status(422)
            |> render("changeset_error.json", %{errors: status.errors})

          {:ok, daily_status} ->
            render(conn, "index.json", daily_status: daily_status)
        end

      404 ->
        conn
        |> put_status(404)
        |> json(%{"workspace_exist" => false})
    end
  end

  def show_daily_status_mail(conn, params) do
    case conn.status do
      nil ->
        %{assigns: %{daily_status_mail: daily_status_mail}} = conn

        with false <- is_nil(daily_status_mail) do
          conn
          |> put_status(200)
          |> render("index_for_show.json", daily_status_mail: daily_status_mail)
        else
          true ->
            conn
            |> put_status(200)
            |> json(%{"Resource Not Found" => true})
        end

      404 ->
        conn
        |> put_status(404)
        |> json(%{"Resource Not Found" => true})
    end
  end

  def update_daily_status_mail(conn, params) do
    case conn.status do
      nil ->
        %{assigns: %{daily_status_mail: daily_status_mail}} = conn

        case DailyStatusMailSettingsModel.update_daily_status_mail_settings(
               daily_status_mail,
               params
             ) do
          {:ok, daily_status_mail} ->
            conn
            |> put_status(200)
            |> render("index_for_show.json", daily_status_mail: daily_status_mail)

          {:error, errors} ->
            conn
            |> put_status(400)
            |> render("changeset_error.json", %{errors: errors.errors})
        end

      404 ->
        conn
        |> put_status(404)
        |> json(%{"Resource Not Found" => true})
    end
  end

  defp load_workspace(%{params: %{"workspace_id" => workspace_id}} = conn, _params) do
    {workspace_id, _} = Integer.parse(workspace_id)
    user = Guardian.Plug.current_resource(conn)

    case WorkspaceModel.get_workspace_by_user(%{user_id: user.id, workspace_id: workspace_id}) do
      workspace ->
        assign(conn, :workspace, workspace)

      nil ->
        conn
        |> put_status(404)
    end
  end

  defp load_daily_status_mail(%{params: %{"workspace_id" => workspace_id}} = conn, _params) do
    {workspace_id, _} = Integer.parse(workspace_id)
    user = Guardian.Plug.current_resource(conn)

    case DailyStatusMailSettingsModel.load_user_specific_status_setting(workspace_id, user.id) do
      daily_status_mail ->
        assign(conn, :daily_status_mail, daily_status_mail)

      nil ->
        conn
        |> put_status(404)
    end
  end
end
