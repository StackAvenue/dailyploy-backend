defmodule Dailyploy.Helper.Seed.Status do
  import Ecto.Query
  alias Dailyploy.Repo
  alias Dailyploy.Schema.Project
  alias Dailyploy.Schema.TaskStatus, as: TSchema
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
      {:ok, _task_status} -> :ok
      {:error, _task_status} -> :ignore
    end
  end

  def seed_status_in_project(project) do
    Enum.each(@project_status, fn task_status -> insert_status(task_status, project) end)
  end

  def seed_sequence() do
    project_ids = extract_project_ids()

    Enum.each(project_ids, fn project_id ->
      insert_sequence(project_id)
    end)
  end

  defp extract_project_ids() do
    query =
      from status in TSchema,
        select: status.project_id,
        distinct: true

    Repo.all(query)
  end

  defp insert_sequence(project_id) do
    query =
      from status in TSchema,
        where: status.project_id == ^project_id

    statuses = Repo.all(query)

    Enum.reduce(statuses, 0, fn status, sequence_no ->
      sequence_no = sequence_no + 1

      case status.name do
        "not_started" ->
          TaskStatus.update(status, %{sequence_no: sequence_no, is_default: true})

        _ ->
          TaskStatus.update(status, %{sequence_no: sequence_no})
      end

      sequence_no
    end)
  end
end
