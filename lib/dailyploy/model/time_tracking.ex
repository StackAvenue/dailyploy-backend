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

  # Have to calculate duration here itself 
  # and then have to append it with the changeset so that duration can go correctly
  # And have to put check wheather the given end time is not less then the start time 
  # Can throw the error

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
end
