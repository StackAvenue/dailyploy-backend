defmodule Dailyploy.Helper.Seed.Task do
  alias Dailyploy.Repo
  alias Dailyploy.Schema.Task
  alias Dailyploy.Model.Task, as: TaskModel
  alias Dailyploy.Model.TaskStatus

  def seed_task() do
    tasks = Repo.all(Task)

    Enum.each(tasks, fn task ->
      task = Repo.preload(task, [:project])
      prepare_task(task)
    end)
  end

  defp prepare_task(task) do
    case task.status do
      "completed" -> prepare_completed(task)
      "running" -> prepare_running(task)
      "not_started" -> prepare_not_started(task)
    end
  end

  defp prepare_completed(task) do
    task_status =
      TaskStatus.get_running_status(task.project_id, task.project.workspace_id, "completed")

    insert_data_into_task(task, task_status)
  end

  defp prepare_running(task) do
    task_status =
      TaskStatus.get_running_status(task.project_id, task.project.workspace_id, "running")

    insert_data_into_task(task, task_status)
  end

  defp prepare_not_started(task) do
    task_status =
      TaskStatus.get_running_status(task.project_id, task.project.workspace_id, "not_started")

    insert_data_into_task(task, task_status)
  end

  defp insert_data_into_task(task, task_status) do
    params = %{task_status_id: task_status.id}
    TaskModel.update_task_status(task, params)
  end

  def change_status() do
    tasks = Repo.all(Task)
    Enum.each(tasks, fn task ->
      task = Repo.preload(task, [:project])
      complete_status_id = TaskStatus.get_running_status(task.project_id, task.project.workspace_id, "completed")
      case task.status do
      "completed" -> TaskModel.update_task(task, %{is_complete: true})
        _ ->
          if complete_status_id == task.task_status_id do
            TaskModel.update_task(task, %{is_complete: true})
          else
            :no_reply
          end
      end
    end)
  end
end
