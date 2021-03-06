defmodule DailyployWeb.TimeTrackingView do
  use DailyployWeb, :view
  alias DailyployWeb.TimeTrackingView
  alias DailyployWeb.ErrorHelpers

  def render("changeset_error.json", %{errors: errors}) do
    %{errors: ErrorHelpers.changeset_error_to_map(errors)}
  end

  def render("task_running.json", %{task_running: task_running}) do
    %{
      id: task_running.id,
      start_time: task_running.start_time,
      status: task_running.status,
      task_id: task_running.task_id
    }
  end

  def render("date_formatted_time_tracks.json", %{time_tracking: {date, time_tracks}}) do
    %{
      date: date,
      time_tracks: render_many(time_tracks, TimeTrackingView, "time_tracks.json")
    }
  end

  def render("task_stopped.json", %{task_stopped: task_stopped}) do
    %{
      id: task_stopped.id,
      end_time: task_stopped.end_time,
      status: task_stopped.status,
      start_time: task_stopped.start_time,
      task_id: task_stopped.task_id,
      duration: task_stopped.duration
    }
  end

  def render("time_tracks.json", %{time_tracking: time_track}) do
    %{
      id: time_track.id,
      end_time: time_track.end_time,
      status: time_track.status,
      start_time: time_track.start_time,
      task_id: time_track.task_id,
      duration: time_track.duration
    }
  end

  def render("task_with_track_time.json", %{time_tracking: time_tracking}) do
    {:ok, %{end_time: end_time, duration: duration}} =
      with false <- is_nil(time_tracking.end_time) do
        {:ok, %{end_time: time_tracking.end_time, duration: time_tracking.duration}}
      else
        true ->
          {:ok, %{end_time: 0, duration: 0}}
      end

    %{
      id: time_tracking.id,
      status: time_tracking.status,
      start_time: time_tracking.start_time,
      task_id: time_tracking.task_id,
      end_time: end_time,
      duration: duration
    }
  end
end
