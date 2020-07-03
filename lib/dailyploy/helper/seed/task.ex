defmodule Dailyploy.Helper.Seed.Task do
  alias Dailyploy.Repo
  alias Dailyploy.Schema.Task
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

    require IEx
    IEx.pry()
  end

  defp prepare_running(task) do
    task_status =
      TaskStatus.get_running_status(task.project_id, task.project.workspace_id, "running")

    require IEx
    IEx.pry()
  end

  defp prepare_not_started(task) do
    task_status =
      TaskStatus.get_running_status(task.project_id, task.project.workspace_id, "not_started")

    require IEx
    IEx.pry()
  end
end
