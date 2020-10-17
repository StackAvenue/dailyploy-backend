defmodule Dailyploy.Schema.TimeTracking do
  use Ecto.Schema
  import Ecto.Changeset
  alias Dailyploy.Schema.Task

  @tracking_status ~w(running stopped)s

  schema("time_tracking") do
    field(:start_time, :utc_datetime)
    field(:end_time, :utc_datetime)
    field(:status, :string, default: "stopped")
    field(:duration, :integer)
    field(:logged_time, :integer, default: 0, null: false)
    field(:time_log, :boolean, default: false)
    belongs_to(:task, Task)

    timestamps()
  end

  @required ~w(task_id status)a
  @running_params ~w(task_id start_time status)a
  @stopped_params ~w(task_id end_time status)a
  @running_optional ~w(end_time logged_time duration time_log)a
  @stopped_optional ~w(start_time logged_time duration time_log)a

  @changeset @running_params ++ @running_optional ++ @stopped_params ++ @stopped_optional

  @running_permitted @running_params ++ @running_optional
  @stopped_permitted @stopped_params ++ @stopped_optional

  def running_changeset(time_tracking, params) do
    time_tracking
    |> cast(params, @running_permitted)
    |> common_changeset()
  end

  def stop_changeset(time_tracking, params) do
    time_tracking
    |> cast(params, @stopped_permitted)
    |> common_changeset()
  end

  def update_changeset(time_tracking, params) do
    time_tracking
    |> cast(params, @changeset)
    |> common_changeset()
  end

  def changeset(time_tracking, params) do
    time_tracking
    |> cast(params, @changeset)
  end

  def tracking_status() do
    @tracking_status
  end

  defp common_changeset(changeset) do
    changeset
    |> validate_required(@required)
    |> validate_inclusion(:status, @tracking_status)
  end
end
