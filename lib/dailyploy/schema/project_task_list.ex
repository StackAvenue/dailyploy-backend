defmodule Dailyploy.Schema.ProjectTaskList do
  use Ecto.Schema
  alias Dailyploy.Schema.{Workspace, Project, User, ProjectTaskList, TaskLists}
  import Ecto.Changeset

  schema "add_project_task_list" do
    field :name, :string
    field :start_date, :date
    field :end_date, :date
    field :description, :string
    field :color_code, :string

    belongs_to :workspace, Workspace
    belongs_to :creator, User
    belongs_to :project, Project

    has_many :task_lists, TaskLists
    timestamps()
  end

  @required_params ~w(name start_date end_date workspace_id creator_id project_id)a
  @optional_params ~w(description color_code)a

  @permitted_params @required_params ++ @optional_params

  def changeset(%ProjectTaskList{} = project_task_list, attrs) do
    project_task_list
    |> cast(attrs, @permitted_params)
    |> validate_required(@required_params)
    |> assoc_constraint(:workspace)
    |> assoc_constraint(:creator)
    |> assoc_constraint(:project)
    |> unique_constraint(:project, name: :unique_project_index)
  end
end
