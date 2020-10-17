defmodule Dailyploy.Schema.RoadmapChecklist do
  use Ecto.Schema
  import Ecto.Changeset
  alias Dailyploy.Schema.{TaskLists, TaskListTasks, UserStories}

  schema "roadmap_checklist" do
    field :name, :string
    field :is_completed, :boolean, default: false, null: false
    belongs_to :user_stories, UserStories
    belongs_to :task_list_tasks, TaskListTasks
    belongs_to :task_lists, TaskLists
    timestamps()
  end

  @required ~w(name is_completed)a
  @optional ~w(task_lists_id user_stories_id task_list_tasks_id)a

  @params @required ++ @optional

  def changeset(%__MODULE__{} = checklist, params) do
    checklist
    |> cast(params, @params)
    |> validate_required(@required)
    |> assoc_constraint(:task_lists)
    |> assoc_constraint(:user_stories)
    |> assoc_constraint(:task_list_tasks)
  end
end
