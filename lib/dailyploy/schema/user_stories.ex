defmodule Dailyploy.Schema.UserStories do
  use Ecto.Schema
  import Ecto.Changeset

  alias Dailyploy.Schema.{
    User,
    TaskListTasks,
    TaskLists,
    TaskComment,
    RoadmapChecklist,
    StoriesAttachments,
    TaskStatus
  }

  @task_priority ~w(low medium high no_priority)s

  schema "user_stories" do
    field :name, :string
    field :description, :string
    field :is_completed, :boolean, default: false, null: false
    field :priority, :string
    field :due_date, :utc_datetime
    # associations
    belongs_to :task_status, TaskStatus
    belongs_to :owner, User
    belongs_to :task_lists, TaskLists
    has_many :comments, TaskComment
    has_many :attachments, StoriesAttachments
    has_many :task_lists_tasks, TaskListTasks
    has_many :roadmap_checklist, RoadmapChecklist
    timestamps()
  end

  @required_params ~w(name task_status_id is_completed task_lists_id)a
  @optional_params ~w(description owner_id priority due_date)a

  @permitted_params @required_params ++ @optional_params

  def changeset(%__MODULE__{} = user_story, params) do
    user_story
    |> cast(params, @permitted_params)
    |> validate_required(@required_params)
    |> assoc_constraint(:owner)
    |> assoc_constraint(:task_lists)
    |> assoc_constraint(:task_status)
    |> validate_inclusion(:priority, @task_priority)
  end

  def task_priority() do
    @task_priority
  end
end
