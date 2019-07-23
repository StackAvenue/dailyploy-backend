defmodule Dailyploy.Model.Workspace do
  alias Dailyploy.Repo
  alias Dailyploy.Schema.Workspace

  @spec list_workspaces :: any
  def list_workspaces() do
    Repo.all(Workspace)
  end

  def get_workspace!(id), do: Repo.get!(Workspace, id)

  def get_workspace!(id, preloads), do: Repo.get!(Workspace, id) |> Repo.preload(preloads)

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
end
