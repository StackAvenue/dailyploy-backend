defmodule Dailyploy.Schema.TaskComment do
  use Ecto.Schema
  import Ecto.Changeset
  alias Dailyploy.Schema.Task
  alias Dailyploy.Schema.UserStories
  alias Dailyploy.Schema.User
  alias Dailyploy.Schema.CommentsAttachment
  alias Dailyploy.Schema.TaskListTasks

  schema("task_comments") do
    field(:comments, :string)
    belongs_to(:task, Task)
    belongs_to(:user, User)
    belongs_to(:user_stories, UserStories)
    belongs_to(:task_list_tasks, TaskListTasks)
    has_many(:attachment, CommentsAttachment)

    timestamps()
  end

  @optional ~w(comments task_id user_stories_id task_list_tasks_id)a
  @required ~w(user_id)a
  @permitted @required ++ @optional

  def changeset(task_comments, attrs) do
    task_comments
    |> cast(attrs, @permitted)
    |> validate_required(@required)
    |> assoc_constraint(:user_stories)
  end
end
