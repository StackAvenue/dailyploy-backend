defmodule Dailyploy.Schema.TaskStatus do
  use Ecto.Schema
  import Ecto.Changeset
  alias Dailyploy.Schema.Workspace
  alias Dailyploy.Schema.Project

  schema "task_status" do
    field :name, :string, null: false
    field :sequence_no, :integer, default: 0, null: false
    field :is_default, :boolean, default: false, null: false
    belongs_to :workspace, Workspace
    belongs_to :project, Project
    timestamps()
  end

  @params ~w(name workspace_id project_id sequence_no is_default)a

  def changeset(task_status, attrs) do
    task_status
    |> cast(attrs, @params)
    |> validate_required(@params)
    |> validate_format(:name, ~r/^[A-Za-z]/)
    |> assoc_constraint(:workspace)
    |> assoc_constraint(:project)
    |> unique_constraint(:name, name: :unique_status_index)
  end
end
