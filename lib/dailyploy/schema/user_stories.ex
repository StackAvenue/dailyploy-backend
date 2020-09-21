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

  schema "user_stories" do
    field :name, :string
    field :description, :string
    field :is_completed, :boolean, default: false, null: false
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
  @optional_params ~w(description owner_id)a

  @permitted_params @required_params ++ @optional_params

  def changeset(%__MODULE__{} = user_story, params) do
    user_story
    |> cast(params, @permitted_params)
    |> validate_required(@required_params)
    |> assoc_constraint(:owner)
    |> assoc_constraint(:task_lists)
    |> assoc_constraint(:task_status)
  end
end
