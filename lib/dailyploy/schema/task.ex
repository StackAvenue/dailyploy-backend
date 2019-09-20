defmodule Dailyploy.Schema.Task do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias Dailyploy.Repo
  alias Dailyploy.Schema.Project
  alias Dailyploy.Schema.User
  alias Dailyploy.Schema.UserWorkspace

  schema "tasks" do
    field :name, :string
    field :start_datetime, :utc_datetime
    field :end_datetime, :utc_datetime
    field :comments, :string

    belongs_to :user, User
    belongs_to :project, Project
    many_to_many :user_workspaces, UserWorkspace, join_through: "user_workspace_tasks"

    timestamps()
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> Repo.preload([:user_workspaces])
    |> cast(attrs, [:name, :start_datetime, :end_datetime, :comments, :project_id, :user_id])
    |> validate_required([:name, :start_datetime, :end_datetime, :project_id, :user_id])
    |> unique_constraint(:name)
    |> assoc_constraint(:project)
    |> put_assoc_user_workspaces(attrs["member_ids"])
  end

  defp put_assoc_user_workspaces(changeset, member_ids) do
    user_workspaces = Repo.all(from(user_workspace in UserWorkspace, where: user_workspace.id in ^member_ids))

    put_assoc(changeset, :user_workspaces, Enum.map(user_workspaces, &change/1))
  end
end
