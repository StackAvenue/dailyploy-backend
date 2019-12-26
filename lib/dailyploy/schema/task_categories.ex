defmodule Dailyploy.Schema.TaskCategory do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias Dailyploy.Repo
  alias Dailyploy.Schema.Workspace
  alias Dailyploy.Schema.WorkspaceTaskCategory

  schema "task_categories" do
    field :name, :string
    many_to_many :workspaces, Workspace, join_through: WorkspaceTaskCategory
    timestamps()
  end

  def changeset(task_category, attrs) do
    task_category
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> validate_format(:name, ~r/^[A-Za-z]/)
    |> put_category_workspace(attrs["workspace_id"])
  end

  defp put_category_workspace(changeset, workspace_id) do
    workspaces = [Repo.get(Workspace, workspace_id)]

    put_assoc(changeset, :workspaces, Enum.map(workspaces, &change/1))
  end
end
