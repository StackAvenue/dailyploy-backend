defmodule Dailyploy.Schema.Task do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias Dailyploy.Repo
  alias Dailyploy.Schema.Project
  alias Dailyploy.Schema.User
  alias Dailyploy.Schema.TaskCategory
  alias Dailyploy.Schema.TaskListTasks
  alias Dailyploy.Schema.TimeTracking
  alias Dailyploy.Schema.TaskComment
  alias Dailyploy.Schema.TaskStatus

  @task_priority ~w(low medium high no_priority)s

  schema "tasks" do
    field :name, :string
    field :start_datetime, :utc_datetime
    field :end_datetime, :utc_datetime
    field :comments, :string
    field :estimation, :float
    field :status, :string, default: "not_started"
    field :priority, :string
    field :is_complete, :boolean, default: false, null: false
    field :identifier, :string
    field :description, :string

    belongs_to :task_status, TaskStatus
    belongs_to :owner, User
    belongs_to :project, Project
    belongs_to :task_list_tasks, TaskListTasks
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
      :task_list_tasks_id,
      :comments,
      :project_id,
      :owner_id,
      :category_id,
      :task_status_id,
      :estimation,
      :priority,
      :identifier,
      :description
    ])
    |> validate_required([
      :name,
      :start_datetime,
      :end_datetime,
      :project_id,
      :owner_id,
      :task_status_id,
      :is_complete
    ])
    |> assoc_constraint(:owner)
    |> assoc_constraint(:project)
    |> assoc_constraint(:task_list_tasks)
    |> assoc_constraint(:task_status)
    |> validate_inclusion(:priority, @task_priority)
    |> put_task_members(attrs["member_ids"])
  end

  def task_list_changeset(task, attrs) do
    task =
      task
      |> cast(attrs, [
        :name,
        :start_datetime,
        :end_datetime,
        :task_list_tasks_id,
        :comments,
        :project_id,
        :owner_id,
        :category_id,
        :task_status_id,
        :estimation,
        :priority,
        :description
      ])
      |> validate_required([
        :name,
        :start_datetime,
        :end_datetime,
        :project_id,
        :task_list_tasks_id,
        :owner_id,
        :is_complete,
        :task_status_id
      ])
      |> assoc_constraint(:owner)
      |> assoc_constraint(:project)
      |> assoc_constraint(:task_list_tasks)
      |> assoc_constraint(:task_status)
      |> foreign_key_constraint(:task_list_tasks)
      |> validate_inclusion(:priority, @task_priority)

    case Map.has_key?(attrs, "member_ids") do
      true -> put_task_members(task, attrs["member_ids"])
      false -> task
    end
  end

  def update_changeset(task, attrs) do
    task =
      task
      |> Repo.preload([:members])
      |> cast(attrs, [
        :name,
        :start_datetime,
        :end_datetime,
        :task_list_tasks_id,
        :comments,
        :project_id,
        :owner_id,
        :category_id,
        :task_status_id,
        :is_complete,
        :estimation,
        :priority,
        :identifier,
        :description
      ])
      |> assoc_constraint(:project)
      |> assoc_constraint(:task_list_tasks)
      |> assoc_constraint(:task_status)
      |> validate_inclusion(:priority, @task_priority)

    case Map.has_key?(attrs, "member_ids") do
      true -> put_task_members(task, attrs["member_ids"])
      false -> task
    end
  end

  def update_status_changeset(task, attrs) do
    task =
      task
      |> Repo.preload([:members])
      |> cast(attrs, [
        :name,
        :start_datetime,
        :end_datetime,
        :task_list_tasks_id,
        :comments,
        :project_id,
        :owner_id,
        :category_id,
        :task_status_id,
        :is_complete,
        :estimation,
        :priority,
        :description
      ])
      |> assoc_constraint(:project)
      |> assoc_constraint(:task_list_tasks)
      |> assoc_constraint(:project)
      |> assoc_constraint(:task_status)
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
