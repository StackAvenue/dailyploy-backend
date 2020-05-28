defmodule Dailyploy.Schema.Task do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias Dailyploy.Repo
  alias Dailyploy.Schema.Project
  alias Dailyploy.Schema.User
  alias Dailyploy.Schema.TaskCategory
  alias Dailyploy.Schema.TimeTracking
  alias Dailyploy.Schema.TaskComment
  alias Dailyploy.Schema.TaskStatus

  @task_priority ~w(low medium high no_priority)s

  schema "tasks" do
    field :name, :string
    field :start_datetime, :utc_datetime
    field :end_datetime, :utc_datetime
    field :comments, :string
    field :priority, :string

    belongs_to :status, TaskStatus
    belongs_to :owner, User
    belongs_to :project, Project
    has_many :time_tracks, TimeTracking
    has_many :task_comments, TaskComment
    many_to_many :members, User, join_through: "user_tasks", on_replace: :delete
    belongs_to :category, TaskCategory
    timestamps()
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [
      :name,
      :start_datetime,
      :end_datetime,
      :comments,
      :project_id,
      :owner_id,
      :category_id,
      :status_id,
      :priority
    ])
    |> validate_required([
      :name,
      :start_datetime,
      :end_datetime,
      :project_id,
      :owner_id,
      :status_id
    ])
    |> assoc_constraint(:owner)
    |> assoc_constraint(:project)
    |> assoc_constraint(:status)
    |> validate_inclusion(:priority, @task_priority)
    |> put_task_members(attrs["member_ids"])
  end

  def update_changeset(task, attrs) do
    task
    |> Repo.preload([:members])
    |> cast(attrs, [
      :name,
      :start_datetime,
      :end_datetime,
      :comments,
      :project_id,
      :category_id,
      :status_id,
      :priority
    ])
    |> assoc_constraint(:project)
    |> assoc_constraint(:status)
    |> validate_inclusion(:priority, @task_priority)
    |> put_task_members(attrs["member_ids"])
  end

  def update_status_changeset(task, attrs) do
    task =
      task
      |> Repo.preload([:members])
      |> cast(attrs, [
        :name,
        :start_datetime,
        :end_datetime,
        :comments,
        :project_id,
        :category_id,
        :status_id,
        :priority
      ])
      |> assoc_constraint(:project)
      |> assoc_constraint(:status)
      |> validate_inclusion(:priority, @task_priority)

    case Map.has_key?(attrs, "member_ids") do
      true -> put_task_members(task, attrs["member_ids"])
      false -> task
    end
  end

  defp put_task_members(changeset, members) do
    members = Repo.all(from(user in User, where: user.id in ^members))

    put_assoc(changeset, :members, Enum.map(members, &change/1))
  end

  def task_priority() do
    @task_priority
  end
end
