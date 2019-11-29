defmodule Dailyploy.Model.Workspace do
  alias Dailyploy.Repo
  alias Dailyploy.Schema.Workspace
  alias Dailyploy.Model.UserWorkspace, as: UserWorkspaceModel
  alias Dailyploy.Schema.UserWorkspace
  import Ecto.Query

  @spec list_workspaces :: any
  def list_workspaces() do
    Repo.all(Workspace)
  end

  def get_workspace_by_user(%{user_id: user_id, workspace_id: workspace_id}) do
    case UserWorkspaceModel.get_user_workspace!(%{user_id: user_id, workspace_id: workspace_id}, [
           :workspace
         ]) do
      %UserWorkspace{} = user_workspace -> user_workspace.workspace
      _ -> nil
    end
  end

  def get_workspace!(id), do: Repo.get(Workspace, id)

  def get_workspace!(id, preloads), do: Repo.get(Workspace, id) |> Repo.preload(preloads)

  def create_workspace(attrs \\ %{}) do
    %Workspace{}
    |> Workspace.changeset(attrs)
    |> Repo.insert()
  end

  def update_workspace(%Workspace{} = workspace, attrs) do
    workspace
    |> Workspace.changeset(attrs)
    |> Repo.update()
  end

  def delete_workspace(%Workspace{} = workspace) do
    Repo.delete(workspace)
  end

  def all_user_workspaces(user) do
    query =
      from user_workspace in UserWorkspace,
        where: user_workspace.user_id == ^user.id

    user_workspaces = Repo.all(query) |> Repo.preload([:workspace])
    Enum.map(user_workspaces, fn user_workspace -> user_workspace.workspace end)
  end
end
