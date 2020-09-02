defmodule Dailyploy.Schema.RoadmapChecklist do
  use Ecto.Schema
  import Ecto.Changeset
  alias Dailyploy.Schema.TaskLists

  schema "roadmap_checklist" do
    field :name, :string
    field :is_completed, :boolean, default: false, null: false
    belongs_to :task_lists, TaskLists
    timestamps()
  end

  @params ~w(name is_completed task_lists_id)a

  def changeset(%__MODULE__{} = checklist, params) do
    checklist
    |> cast(params, @params)
    |> validate_required(@params)
    |> assoc_constraint(:task_lists)
  end
end
