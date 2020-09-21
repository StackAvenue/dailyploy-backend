defmodule Dailyploy.Schema.UserStories do
  use Ecto.Schema
  import Ecto.Changeset
  alias Dailyploy.Schema.{User, TaskListTasks, TaskLists, TaskComment, RoadmapChecklist}

  @task_status ~w(completed running not_started)s

  schema "user_stories" do
    field :name, :string
    field :description, :string
    field :status, :string
    field :is_completed, :boolean, default: false, null: false
    # associations
    belongs_to :owner, User
    belongs_to :task_lists, TaskLists
    has_many :comments, TaskComment
    has_many :attachments, StoriesAttachments
    has_many :task_lists_tasks, TaskListTasks
    has_many :roadmap_checklist, RoadmapChecklist
  end

  @required_params ~w(name status is_completed owner_id task_lists_id)a
  @optional_params ~w(description)a

  @permitted_params @required_params ++ @optional_params

  def changeset(%__MODULE__{} = user_story, params) do
    user_story
    |> cast(params, @permitted_params)
    |> validate_required(@required_params)
    |> assoc_constraint(:owner)
    |> assoc_constraint(:task_lists)
    |> validate_inclusion(:status, @task_status)
  end

  def task_status() do
    @task_status
  end
end
