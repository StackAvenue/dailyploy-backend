defmodule Dailyploy.Schema.TaskAssignee do
  use Ecto.Schema
  import Ecto.Changeset
  alias Dailyploy.Schema.User
  alias Dailyploy.Schema.Task

  schema "task_assignees" do
   belongs_to :user, User
   belongs_to :task, Task

   timestamps()
  end

  def changeset(taskassignee, attrs) do
    taskassignee
    |> cast(attrs, [:user_id, :task_id])
    |> validate_required([:user_id, :task_id])
    |> unique_constraint(:user_task_uniqueness, name: :unique_index_for_user_and_task_in_taskassignee)
  end
end

