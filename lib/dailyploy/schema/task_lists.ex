defmodule Dailyploy.Schema.TaskLists do
  use Ecto.Schema
  alias Dailyploy.Schema.{TaskCategory, User, ProjectTaskList, TaskLists}
  import Ecto.Changeset

  @task_status ~w(completed running not_started)s
  @task_priority ~w(low medium high no_priority)s

  schema "add_task_lists" do
    field :name, :string
    field :description, :string
    field :estimation, :integer
    field :status, :string, default: "not_started"
    field :priority, :string, default: "no_priority"

    belongs_to :owner, User
    belongs_to :category, TaskCategory
    belongs_to :project_task_list, ProjectTaskList

    timestamps()
  end

  @required_params ~w(name estimation owner_id project_task_list_id)a
  @optional_params ~w(description status priority category_id)a

  @permitted_params @required_params ++ @optional_params

  def changeset(%TaskLists{} = task_lists, attrs) do
    task_lists
    |> cast(attrs, @permitted_params)
    |> validate_required(@required_params)
    |> assoc_constraint(:owner)
    |> assoc_constraint(:project_task_list)
    |> validate_inclusion(:status, @task_status)
    |> validate_inclusion(:priority, @task_priority)
  end

  def task_status() do
    @task_status
  end

  def task_priority() do
    @task_priority
  end
end
