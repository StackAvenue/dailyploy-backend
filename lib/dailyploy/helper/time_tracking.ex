defmodule Dailyploy.Helper.TimeTracking do
  alias Dailyploy.Repo
  # alias Dailyploy.Schema.UserTask
  # alias Dailyploy.Schema.Project
  # alias Dailyploy.Schema.TimeTracking
  # alias Dailyploy.Schema.Task
  alias Dailyploy.Model.TaskStatus
  # alias Dailyploy.Helper.Firebase
  alias Dailyploy.Model.TimeTracking, as: TTModel
  alias Dailyploy.Model.Task, as: TaskModel
  # import Ecto.Query
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
    task = TaskModel.get_task!(running_status.task_id) |> Repo.preload([:project])

    task_status =
      TaskStatus.get_running_status(task.project_id, task.project.workspace_id, "running")

    status_id =
      case task_status do
        nil ->
          params = %{
            workspace_id: task.project.workspace_id,
            project_id: task.project_id,
            name: "running"
          }

          {:ok, status} = TaskStatus.create(params)
          status.id

        _anything ->
          task_status.id
      end

    params = %{"status_id" => status_id}

    case TaskModel.update_task_status(task, params) do
      {:ok, _task} ->
        {:ok,
         %{
           id: running_status.id,
           task_id: running_status.task_id,
           start_time: running_status.start_time,
           status: running_status.status
         }}

      {:error, _task} ->
        {:ok,
         %{
           id: running_status.id,
           task_id: running_status.task_id,
           start_time: running_status.start_time,
           status: running_status.status
         }}
    end
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

  # def toggle_task(task) do
  #   task = Repo.preload(task, [:project, :members])
  #   user = List.first(task.members)
  #   workspace_id = task.project.workspace_id

  #   query =
  #     from(time_tracking in TimeTracking,
  #       join: task in Task,
  #       join: project in Project,
  #       join: user_task in UserTask,
  #       on:
  #         task.id == time_tracking.task_id and task.project_id == project.id and
  #           project.workspace_id == ^workspace_id and user_task.user_id == ^user.id and
  #           user_task.task_id == task.id,
  #       where: time_tracking.status == "running"
  #     )

  #   previous_running_task = List.first(Repo.all(query))

  #   with false <- is_nil(previous_running_task),
  #        do: switch_task_status(previous_running_task, task)
  # end

  # defp switch_task_status(previous_running_task, task) do
  #   params = %{
  #     end_time: DateTime.to_string(DateTime.utc_now()),
  #     status: "stopped",
  #     task_id: previous_running_task.task_id
  #   }

  #   {:ok, task_stopped} = stop_running(previous_running_task, params)

  #   Firebase.insert_operation(
  #     Jason.encode(task_stopped),
  #     "task_status/#{task.project.workspace_id}/#{task_stopped.task_id}"
  #   )
  # end
end
