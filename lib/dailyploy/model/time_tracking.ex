defmodule Dailyploy.Model.TimeTracking do
  import Ecto.Query
  alias Dailyploy.Repo
  alias Dailyploy.Schema.TimeTracking
  alias Dailyploy.Model.TimeTracking, as: TTModel
  use Timex

  def start_running(params) do
    changeset = TimeTracking.running_changeset(%TimeTracking{}, params)
    Repo.insert(changeset)
  end

  def create(params) do
    changeset = TimeTracking.running_changeset(%TimeTracking{}, params)
    Repo.insert(changeset)
  end

  def delete_time_track(time_track) do
    Repo.delete(time_track)
  end

  # Have to calculate duration here itself
  # and then have to append it with the changeset so that duration can go correctly
  # And have to put check wheather the given end time is not less then the start time
  # Can throw the error

  def create_logged_task({:ok, params}) do
    duration = DateTime.diff(params.end_datetime, params.start_datetime)

    params = %{
      task_id: params.id,
      start_time: params.start_datetime,
      end_time: params.end_datetime,
      time_log: true,
      duration: duration
    }

    changeset = TimeTracking.changeset(%TimeTracking{}, params)
    asd = Repo.insert(changeset)
  end

  def find_with_task_id(task_id) do
    query =
      from time_tracks in TimeTracking,
        where: time_tracks.task_id == ^task_id

    List.first(Repo.all(query))
  end

  def stop_running(running_task, params) do
    changeset = TimeTracking.stop_changeset(running_task, params)

    with {:ok, duration} <- calculate_duration(changeset, params) do
      changes = Map.put(changeset.changes, :duration, duration)
      changeset = Map.replace!(changeset, :changes, changes)
      Repo.update(changeset)
    else
      {:error, message} -> {:error, message}
    end
  end

  defp calculate_duration(changeset, params) do
    {:ok, task_tracked} = TTModel.get(params.task_id)

    case DateTime.diff(changeset.changes.end_time, task_tracked.start_time) >= 0 do
      true -> {:ok, DateTime.diff(changeset.changes.end_time, task_tracked.start_time)}
      false -> {:error, "end time is wrong"}
    end
  end

  def get(id) when is_integer(id) do
    query =
      from(task_running in TimeTracking,
        where: task_running.task_id == ^id and task_running.status == "running",
        select: task_running
      )

    task_tracked = List.first(Repo.all(query))

    case is_nil(task_tracked) do
      false -> {:ok, task_tracked}
      true -> {:error, "task not running"}
    end
  end

  def calculate_task_duration(task_id) when is_integer(task_id) do
    query =
      from(time_tracks in TimeTracking,
        where: time_tracks.task_id == ^task_id and time_tracks.status == "stopped",
        select: fragment("SUM(?)", time_tracks.duration)
      )

    Repo.one(query)
  end

  def calculate_task_duration(task_id, date) when is_integer(task_id) do
    query =
      from(time_tracks in TimeTracking,
        where:
          time_tracks.task_id == ^task_id and time_tracks.status == "stopped" and
            time_tracks.start_time == ^date,
        select: fragment("SUM(?)", time_tracks.duration)
      )

    asd = Repo.one(query)
  end

  defp change_duration(start_time, end_time) do
    case DateTime.diff(end_time, start_time) >= 0 do
      true -> {:ok, DateTime.diff(end_time, start_time)}
      false -> {:error, "end time is wrong"}
    end
  end

  def update_tracked_time(time_tracked, params) do
    params = map_to_atom(params)
    params = Map.replace!(params, :task_id, String.to_integer(params.task_id))
    changeset = TimeTracking.update_changeset(time_tracked, params)

    with {:ok, time_tracked} <- Repo.update(changeset) do
      with {:ok, duration} <- change_duration(time_tracked.start_time, time_tracked.end_time) do
        changes = Map.put(changeset.changes, :duration, duration)
        changeset = Map.replace!(changeset, :changes, changes)
        Repo.update(changeset)
      else
        {:error, message} -> {:error, message}
      end
    else
      {:error, message} -> {:error, message}
    end
  end

  def get_time_tracked(id, task_id) when is_integer(id) do
    query =
      from(task_running in TimeTracking,
        where: task_running.task_id == ^task_id and task_running.id == ^id,
        select: task_running
      )

    task_tracked = List.first(Repo.all(query))

    case is_nil(task_tracked) do
      false -> {:ok, task_tracked}
      true -> {:error, "not found"}
    end
  end

  defp map_to_atom(params) do
    for {key, value} <- params, into: %{}, do: {String.to_atom(key), value}
  end
end
