defmodule Dailyploy.Schema.TaskAssignee do
  use Ecto.Schema
  import Ecto.Changeset
  alias Dailyploy.Schema.Project
  alias Dailyploy.Schema.User

  schema "assignees" do
   belongs_to :project, Project
   belongs_to :user, User
  end

  def changeset(taskassignee, attrs) do
    taskassignee
    |> cast(attrs, [:project_id, :user_id])
    |> validate_required([:project_id, :user_id])
  end
end
