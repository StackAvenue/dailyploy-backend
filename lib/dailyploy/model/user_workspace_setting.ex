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
    check_for_update(user, workspace_id)
    # show_all_the_admins_in_current_workspace(workspace_id)
  end

  defp check_for_update(user, workspace_id) do
    {:ok, current_name} = Map.fetch(user, "name")
    {:ok, current_currency} = Map.fetch(user, "currency")
    workspace = WorkspaceModel.get_workspace!(workspace_id)
    {:ok, actual_name} = Map.fetch(workspace, :name)
    {:ok, actual_currency} = Map.fetch(workspace, :currency)

    case workspace do
      nil ->
        :error

      _ ->
        cond do
          current_name !== actual_name ->
            workspace_change = %{"name" => current_name}

            with {:ok, %Workspace{} = workspace} <-
                   WorkspaceModel.update_workspace(workspace, workspace_change) do
              workspace
            end

          current_currency !== actual_currency ->
            workspace_change = %{"currency" => current_currency}

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

  def capacity(
        %{
          "start_date" => start_date,
          "end_date" => end_date,
          "user_ids" => user_ids,
          "workspace_id" => workspace_id
        } = params
      ) do
    user_ids = map_to_list(user_ids)

    query =
      from uwsetting in UserWorkspaceSetting,
        where: uwsetting.workspace_id == ^workspace_id and uwsetting.user_id in ^user_ids,
        select: sum(uwsetting.working_hours)

    result = Repo.one(query)

    no_of_days =
      case Date.diff(end_date, start_date) do
        0 -> 1
        6 -> 5
        _ -> 20
      end

    result * no_of_days * 3600
  end

  defp map_to_list(user_ids) do
    user_ids
    |> String.split(",")
    |> Enum.map(fn x -> String.to_integer(String.trim(x, " ")) end)
  end
end
