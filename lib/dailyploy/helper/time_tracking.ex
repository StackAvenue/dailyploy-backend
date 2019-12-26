defmodule Dailyploy.Helper.TimeTracking do
  alias Dailyploy.Model.TimeTracking, as: TTModel
  import DailyployWeb.Helpers

  def start_running(params) do
    %{
      task_id: task_id,
      start_time: start_time,
      status: status
    } = params

    verify_running(
      TTModel.start_running(%{
        task_id: task_id,
        start_time: start_time,
        status: status
      })
    )
  end

  def stop_running(running_task, params) do
    %{
      task_id: task_id,
      end_time: end_time,
      status: status
    } = params

    verify_stop(
      TTModel.stop_running(
        running_task,
        %{
          task_id: task_id,
          end_time: end_time,
          status: status
        }
      )
    )
  end

  defp verify_running({:ok, running_status}) do
    {:ok,
     %{
       id: running_status.id,
       task_id: running_status.task_id,
       start_time: running_status.start_time,
       status: running_status.status
     }}
  end

  defp verify_running({:error, running_status}) do
    {:error, %{error: extract_changeset_error(running_status)}}
  end

  defp verify_stop({:ok, running_status}) do
    {:ok,
     %{
       id: running_status.id,
       task_id: running_status.task_id,
       end_time: running_status.end_time,
       start_time: running_status.start_time,
       status: running_status.status,
       duration: running_status.duration
     }}
  end

  defp verify_stop({:error, running_status}) do
    {:error, %{error: running_status}}
  end
end
