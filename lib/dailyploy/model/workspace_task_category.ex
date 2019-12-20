defmodule Dailyploy.Model.WorkspaceTaskCategory do
  alias Dailyploy.Repo
  alias Dailyploy.Schema.Workspace
  alias Dailyploy.Schema.Task
  alias Dailyploy.Schema.TaskCategory
  alias Dailyploy.Schema.WorkspaceTaskCategory
  import Ecto.Query

  def create(attrs \\ %{}) do
    %WorkspaceTaskCategory{}
    |> WorkspaceTaskCategory.changeset(attrs)
    |> Repo.insert()
  end

  def update_workspace_task_category(%WorkspaceTaskCategory{} = workspace_task_category, attrs) do
    workspace_task_category
    |> WorkspaceTaskCategory.changeset(attrs)
    |> Repo.update()
  end

  def delete_workspace_task_category(%WorkspaceTaskCategory{} = workspace_task_category) do
    Repo.delete(workspace_task_category)
  end

  def list_all_workspace_task_category() do
    Repo.all(WorkspaceTaskCategory)
  end

  def delete(workspace_task_category) do
    Repo.delete(workspace_task_category)
  end

  def get(id) when is_integer(id) do
    case Repo.get(WorkspaceTaskCategory, id) do
      nil ->
        {:error, "not found"}

      workspace_task_category ->
        {:ok, workspace_task_category}
    end
  end
end
