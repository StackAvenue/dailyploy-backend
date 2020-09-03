defmodule Dailyploy.Schema.Milestone do
  use Ecto.Schema
  import Ecto.Changeset

  alias Dailyploy.Schema.Project

  schema "milestones" do
    field :name, :string, null: false
    field :description, :string
    field :due_date, :utc_datetime, null: false
    field :status, MilestoneTypeEnum

    belongs_to :project, Project
    timestamps()
  end

  def changeset(milestone, attrs) do
    milestone
    |> cast(attrs, [:name, :description, :due_date, :status, :project_id])
    |> validate_required([:name, :due_date])
    |> assoc_constraint(:project)
  end

  def update_changeset(milestone, attrs) do
    milestone
    |> cast(attrs, [:name, :description, :due_date, :status])
  end
end
