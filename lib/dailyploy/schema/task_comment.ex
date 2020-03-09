defmodule Dailyploy.Schema.TaskComment do
  use Ecto.Schema
  import Ecto.Changeset
  alias Dailyploy.Schema.Task
  alias Dailyploy.Schema.User
  alias Dailyploy.Schema.CommentsAttachment

  schema("task_comments") do
    field(:comments, :string)
    belongs_to(:task, Task)
    belongs_to(:user, User)
    has_many(:attachment, CommentsAttachment)

    timestamps()
  end

  @changeset ~w(task_id user_id comments)a

  def changeset(task_comments, attrs) do
    task_comments
    |> cast(attrs, @changeset)
    |> validate_required(@changeset)
  end
end
