defmodule Dailyploy.Schema.RecurringTask do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Dailyploy.Repo
  alias Dailyploy.Schema.TaskCategory
  alias Dailyploy.Schema.TimeTracking
  alias Dailyploy.Schema.TaskComment
  alias Dailyploy.Schema.Workspace
  alias Dailyploy.Model.Project
  alias Dailyploy.Model.User

  @task_status ~w(completed running not_started)s
  @task_priority ~w(low medium high no_priority)s
  @frequency ~w(daily weekly monthly)s
  @schedule ~w(true false)a

  schema "recurring_tasks" do
    field :name, :string
    field :start_datetime, :utc_datetime
    field :end_datetime, :utc_datetime
    field :comments, :string
    field(:project, {:array, :map}, virtual: true)
    field(:member, {:array, :map}, virtual: true)
    field :status, :string, default: "not_started"
    field :priority, :string
    field :project_ids, {:array, :integer}
    field :member_ids, {:array, :integer}
    field :frequency, :string
    field :number, :integer
    field :schedule, :boolean, default: true
    field :week_numbers, {:array, :integer}
    field :month_numbers, {:array, :integer}
    field :project_members_combination, :map
    has_many :time_tracks, TimeTracking
    has_many :task_comments, TaskComment
    belongs_to :workspace, Workspace
    belongs_to :category, TaskCategory
    timestamps()
  end

  @doc false
  def changeset(recurring_task, attrs) do
    recurring_task
    |> cast(attrs, [
      :name,
      :schedule,
      :start_datetime,
      :end_datetime,
      :comments,
      :project_ids,
      :project_members_combination,
      :member_ids,
      :category_id,
      :workspace_id,
      :status,
      :priority,
      :frequency,
      :number,
      :week_numbers,
      :month_numbers
    ])
    |> validate_required([
      :name,
      :start_datetime,
      :project_ids,
      :member_ids,
      :category_id,
      :workspace_id,
      :project_members_combination,
      :frequency
    ])
    |> validate_inclusion(:status, @task_status)
    |> validate_inclusion(:priority, @task_priority)
    |> validate_inclusion(:schedule, @schedule)
    |> validate_inclusion(:frequency, @frequency)
  end

  def update_changeset(recurring_task, attrs) do
    recurring_task
    |> cast(attrs, [
      :name,
      :schedule,
      :start_datetime,
      :end_datetime,
      :comments,
      :project_ids,
      :member_ids,
      :category_id,
      :status,
      :priority,
      :frequency,
      :number,
      :workspace_id,
      :project_members_combination,
      :week_numbers,
      :month_numbers
    ])
    |> validate_inclusion(:status, @task_status)
    |> validate_inclusion(:priority, @task_priority)
    |> validate_inclusion(:schedule, @schedule)
    |> validate_inclusion(:frequency, @frequency)
  end

  def task_status() do
    @task_status
  end

  def task_priority() do
    @task_priority
  end

  def schedule() do
    @schedule
  end

  def frequency() do
    @frequency
  end
end
