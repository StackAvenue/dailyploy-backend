defmodule Dailyploy.Model.Task do
  import Ecto.Query, only: [from: 2]

  alias Dailyploy.Repo
  alias Dailyploy.Schema.Task
  alias Dailyploy.Schema.Project

  def list_tasks(project_id) do
    query =
      from(task in Task,
        where: task.project_id == ^project_id,
        order_by: task.inserted_at
      )

    Repo.all(query)
  end

  def list_workspace_tasks(workspace_id) do
    project_query = from(project in Project, where: project.workspace_id == ^workspace_id, select: project.id)
    project_ids = Repo.all project_query

    task_query = from(task in Task, where: task.project_id in ^project_ids)
    Repo.all task_query
  end

  def get_task!(id), do: Repo.get(Task, id)

  def create_task(attrs \\ %{}) do
    %Task{}
    |> Task.changeset(attrs)
    |> Repo.insert()
  end

  def update_task(task, attrs) do
    task
    |> Task.changeset(attrs)
    |> Repo.update()
  end

  def delete_task(task) do
    Repo.delete(task)
  end
end
