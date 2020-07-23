defmodule Dailyploy.Schema.TaskLists do
  use Ecto.Schema
  alias Dailyploy.Schema.{Workspace, Project, User, TaskListTasks}
  import Ecto.Changeset

  schema "task_lists" do
    field :name, :string
    field :start_date, :date
    field :end_date, :date
    field :description, :string
    field :color_code, :string

    belongs_to :workspace, Workspace
    belongs_to :creator, User
    belongs_to :project, Project

    has_many :task_list_tasks, TaskListTasks
    timestamps()
  end

  @required_params ~w(name start_date end_date workspace_id creator_id project_id)a
  @optional_params ~w(description color_code)a

  @permitted_params @required_params ++ @optional_params

  def changeset(%__MODULE__{} = task_lists, attrs) do
    task_lists
    |> cast(attrs, @permitted_params)
    |> validate_required(@required_params)
    |> assoc_constraint(:workspace)
    |> assoc_constraint(:creator)
    |> assoc_constraint(:project)
    |> unique_constraint(:project, name: :unique_name_per_project)
  end
end
