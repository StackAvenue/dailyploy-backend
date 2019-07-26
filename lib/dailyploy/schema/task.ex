defmodule Dailyploy.Schema.Task do
  use Ecto.Schema
  alias Dailyploy.Schema.Project
  alias Dailyploy.Schema.User
  alias Dailyploy.Schema.TaskAssignee
  import Ecto.Changeset

  schema "tasks" do
    field :name, :string
    field :description, :string
    field :type, StatusTypeEnum
    field :start_date, :utc_datetime
    field :end_date, :utc_datetime
    belongs_to :project, Project
    many_to_many :users, User, join_through: TaskAssignee

    timestamps(type: :utc_datetime)
  end


  def changeset(task, attrs) do
    task
    |> cast(attrs, [:name, :description, :type, :start_date, :end_date, :project_id])
    |> validate_required([:name, :description, :type, :project_id])
  end
end
