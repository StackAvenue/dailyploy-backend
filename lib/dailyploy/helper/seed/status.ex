defmodule Dailyploy.Helper.Seed.Status do
  alias Dailyploy.Repo
  alias Dailyploy.Schema.Project
  alias Dailyploy.Model.TaskStatus

  @task_status ~w(completed running not_started)s
  @project_status ~w(not_started)s

  def seed_status() do
    projects = Repo.all(Project)
    Enum.each(projects, fn project -> prepare_status(project) end)
  end

  defp prepare_status(project) do
    Enum.each(@task_status, fn task_status -> insert_status(task_status, project) end)
  end

  defp insert_status(task_status, project) do
    params = %{name: task_status, project_id: project.id, workspace_id: project.workspace_id}

    case TaskStatus.create(params) do
      {:ok, task_status} -> :ok
      {:error, task_status} -> :ignore
    end
  end

  def seed_status_in_project(project) do
    Enum.each(@project_status, fn task_status -> insert_status(task_status, project) end)
  end
end
