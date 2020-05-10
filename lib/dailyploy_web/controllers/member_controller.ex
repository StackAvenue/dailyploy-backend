defmodule DailyployWeb.MemberController do
  use DailyployWeb, :controller
  alias Dailyploy.Model.UserWorkspace, as: UserWorkspaceModel
  alias Dailyploy.Model.UserWorkspaceSetting, as: UserWorkspaceSettingsModel

  # alias Dailyploy.Model.Invitation, as: InvitationModel

  alias Dailyploy.Model.User, as: UserModel
  alias Dailyploy.Schema.Project
  alias Dailyploy.Repo

  plug Auth.Pipeline

  action_fallback DailyployWeb.FallbackController

  def index(conn, params) do
    query_params = map_to_atom(params)
    query = UserModel.generate_query(query_params)
    # asd = UserModel.filter_users(query_params)
    members = UserModel.filter_users(query_params) |> Repo.preload(projects: query)

    # member_settings = UserWorkspaceSettingsModel.list_user_workspace_settings(workspace_id)

    member_results =
      Enum.map(members, fn member ->
        user_workspace_setting =
          UserModel.list_user_workspace_setting(member.id, query_params.workspace_id)

        %{member: member, user_workspace_setting: user_workspace_setting}
      end)

    render(conn, "index_with_projects.json", members: member_results)
  end

  def show(conn, %{"workspace_id" => workspace_id, "id" => id}) do
    member =
      UserWorkspaceModel.get_user_workspace!(%{user_id: id, workspace_id: workspace_id}, [
        :user,
        :role
      ])

    render(conn, "member.json", member: member)
  end

  def update(
        conn,
        %{
          "id" => user_id,
          "role_id" => role_id,
          "working_hours" => working_hours,
          "workspace_id" => workspace_id
        } = attrs
      ) do
    user_workspace =
      UserWorkspaceModel.get_user_workspace!(%{user_id: user_id, workspace_id: workspace_id})

    case UserWorkspaceModel.update_user_workspace(user_workspace, %{
           user_id: user_id,
           workspace_id: workspace_id,
           role_id: role_id
         }) do
      {:ok, _} ->
        user_workspace_settings =
          UserWorkspaceSettingsModel.get_user_workspace_settings!(%{
            user_id: user_id,
            workspace_id: workspace_id
          })

        case UserWorkspaceSettingsModel.update_user_workspace_settings(user_workspace_settings, %{
               user_id: user_id,
               workspace_id: workspace_id,
               working_hours: working_hours
             }) do
          {:ok, _} ->
            conn
            |> json(%{
              "user_id" => user_id,
              "role_id" => role_id,
              "working_hours" => working_hours,
              "workspace_id" => workspace_id
            })

          {:error, _} ->
            send_resp(conn, 404, "Not Found")
        end

      {:error, _} ->
        send_resp(conn, 404, "Not Found")
    end
  end

  def delete(conn, %{"id" => user_id, "workspace_id" => workspace_id}) do
    user_workspace =
      UserWorkspaceModel.get_user_workspace!(%{user_id: user_id, workspace_id: workspace_id})

    user_workspace_settings =
      UserWorkspaceSettingsModel.get_user_workspace_settings!(%{
        user_id: user_id,
        workspace_id: workspace_id
      })

    case UserWorkspaceModel.delete_user_workspace(user_workspace) do
      {:ok, _} ->
        case UserWorkspaceSettingsModel.delete_user_workspace_settings(user_workspace_settings) do
          {:ok, _} -> send_resp(conn, 200, "User Successfully deleted from Workspace")
          {:error, _} -> send_resp(conn, 404, "Not Found")
        end

      {:error, _} ->
        send_resp(conn, 404, "Not Found")
    end
  end

  defp map_to_atom(params) do
    for {key, value} <- params, into: %{}, do: {String.to_atom(key), value}
  end
end
