defmodule Dailyploy.Schema.WorkspaceTaskCategory do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Dailyploy.Repo
  alias Dailyploy.Schema.Workspace
  alias Dailyploy.Schema.Task
  alias Dailyploy.Schama.TaskCategory

  schema "workspace_task_categories" do
    belongs_to :workspace, Workspace
    belongs_to :task, Task
    belongs_to :category, TaskCategory

    timestamps()
  end

  def changeset(workspace_task_category, attrs) do
    workspace_task_category
    |> cast(attrs, [:workspace_id, :task_id, :category_id])
    |> validate_required([:workspace_id, :task_id, :category_id])
  end
end
