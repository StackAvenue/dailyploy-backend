defmodule Dailyploy.Schema.WorkspaceTaskCategory do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Dailyploy.Repo
  alias Dailyploy.Schema.Workspace
  alias Dailyploy.Schema.Task
  alias Dailyploy.Schama.TaskCategory

  @already_exist "Category already exist in the workspace"

  schema "workspace_task_categories" do
    belongs_to :workspace, Workspace
    belongs_to :task_category, TaskCategory

    timestamps()
  end

  def changeset(workspace_task_category, attrs) do
    workspace_task_category
    |> cast(attrs, [:workspace_id, :task_category_id])
    |> validate_required([:workspace_id, :task_category_id])
    |> unique_constraint(:workspace_task_category_uniqueness, name: :unique_index_for_workspace_and_category, message: @already_exist)
  end
end
