defmodule Dailyploy.Model.UserWorkspaceSetting do
  alias Dailyploy.Repo
  import Ecto.Query
  alias Dailyploy.Schema.Workspace
  alias Dailyploy.Schema.UserWorkspaceSetting
  # alias Dailyploy.Model.User, as: UserModel
  alias Dailyploy.Model.Workspace, as: WorkspaceModel
  alias Dailyploy.Model.UserWorkspace, as: UserWorkspaceModel
  # alias Auth.Guardian

  def create_user_workspace_settings(attrs \\ %{}) do
    %UserWorkspaceSetting{}
    |> UserWorkspaceSetting.changeset(attrs)
    |> Repo.insert()
  end

  def update_user_workspace_settings(user_workspace_settings, attrs) do
    user_workspace_settings
    |> UserWorkspaceSetting.changeset(attrs)
    |> Repo.update()
  end

  def update(%{"user" => user, "workspace_id" => workspace_id} = workspace_params) do
    check_for_name_update(user, workspace_id)
    # show_all_the_admins_in_current_workspace(workspace_id)
  end

  defp check_for_name_update(user, workspace_id) do
    {:ok, current_name} = Map.fetch(user, "name")
    workspace = WorkspaceModel.get_workspace!(workspace_id)
    {:ok, actual_name} = Map.fetch(workspace, :name)

    case workspace do
      nil ->
        :error

      _ ->
        with current_name !== actual_name do
          workspace_change = %{"name" => current_name}

          with {:ok, %Workspace{} = workspace} <-
                 WorkspaceModel.update_workspace(workspace, workspace_change) do
            workspace
          end
        end
    end
  end

  def list_user_workspace_settings(workspace_id) do
    from(user_workspace_setting in UserWorkspaceSetting,
      where: user_workspace_setting.workspace_id == ^workspace_id
    )
    |> Repo.all()
  end

  defp show_all_the_admins_in_current_workspace(workspace_id) do
    UserWorkspaceModel.get_all_admins_using_workspace_id(workspace_id)
  end

  def get_user_workspace_settings_id(workspace_id) do
    query =
      from user_workspace_settings in UserWorkspaceSetting,
        where: user_workspace_settings.workspace_id == ^workspace_id

    List.first(Repo.all(query))
  end

  def get_user_workspace_settings!(%{user_id: user_id, workspace_id: workspace_id}) do
    query =
      from user_workspace_settings in UserWorkspaceSetting,
        where:
          user_workspace_settings.user_id == ^user_id and
            user_workspace_settings.workspace_id == ^workspace_id

    List.first(Repo.all(query))
  end

  def delete_user_workspace_settings(%UserWorkspaceSetting{} = user_workspace_settings) do
    Repo.delete(user_workspace_settings)
  end
end
