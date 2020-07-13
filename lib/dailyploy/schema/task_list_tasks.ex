defmodule Dailyploy.Schema.TaskListTasks do
  use Ecto.Schema
  alias Dailyploy.Schema.{TaskCategory, User, TaskLists, Task}
  import Ecto.Changeset

  @task_status ~w(completed running not_started)s
  @task_priority ~w(low medium high no_priority)s

  schema "task_list_tasks" do
    field :name, :string
    field :description, :string
    field :estimation, :integer
    field :status, :string, default: "not_started"
    field :priority, :string, default: "no_priority"

    belongs_to :owner, User
    belongs_to :category, TaskCategory
    belongs_to :task_lists, TaskLists
    belongs_to :task, Task

    timestamps()
  end

  @required_params ~w(name task_lists_id)a
  @optional_params ~w(description owner_id estimation status priority category_id task_id)a

  @permitted_params @required_params ++ @optional_params

  def changeset(%__MODULE__{} = task_list_tasks, attrs) do
    task_list_tasks
    |> cast(attrs, @permitted_params)
    |> validate_required(@required_params)
    |> assoc_constraint(:owner)
    |> assoc_constraint(:task_lists)
    |> assoc_constraint(:task)
    |> assoc_constraint(:category)
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
