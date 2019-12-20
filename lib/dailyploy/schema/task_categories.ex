defmodule Dailyploy.Schema.TaskCategory do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias Daily.Repo
  alias Dailyploy.Schema.WorkspaceTaskCategory

  schema "task_categories" do
    field :name, :string
    many_to_many :task_category, WorkspaceTaskCategory, join_through: "workspace_task_categories"
    timestamps()
  end

  def changeset(task_categories, attrs) do
    task_categories
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> validate_format(:name, ~r/^[A-Za-z]/)
  end
end
