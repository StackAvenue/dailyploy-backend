defmodule Dailyploy.Schema.UserTask do
  use Ecto.Schema
  import Ecto.Changeset
  alias Dailyploy.Schema.User
  alias Dailyploy.Schema.Task

  schema "user_tasks" do
    belongs_to :user, User
    belongs_to :task, Task

    timestamps()
  end

  def changeset(user_task, attrs) do
    user_task
    |> cast(attrs, [:user_id, :task_id])
    |> validate_required([:user_id, :task_id])
    |> unique_constraint(:user_task_uniqueness,
      name: :unique_index_for_user_and_task_in_user_task
    )
  end
end
