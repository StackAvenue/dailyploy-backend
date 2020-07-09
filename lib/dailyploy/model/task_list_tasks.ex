defmodule Dailyploy.Model.TaskListTasks do
  # import Ecto.Query
  alias Dailyploy.Repo
  alias Dailyploy.Schema.TaskListTasks

  def create(params) do
    changeset = TaskListTasks.changeset(%TaskListTasks{}, params)
    Repo.insert(changeset)
  end

  def delete(task_list_tasks) do
    Repo.delete(task_list_tasks)
  end

  def update(%TaskListTasks{} = task_list_tasks, params) do
    changeset = TaskListTasks.changeset(task_list_tasks, params)
    Repo.update(changeset)
  end

  # def get(id), do: Repo.get(TaskListTasks, id) |> Repo.preload([:owner, :category, :project_task_list])

  def get(id) when is_integer(id) do
    case Repo.get(TaskListTasks, id) do
      nil ->
        {:error, "not found"}

      task_list_tasks ->
        {:ok, task_list_tasks |> Repo.preload([:owner, :category, :task_lists, :task])}
    end
  end

  # def get_all(project) do
  #   query =
  #     from task_list_tasks in TaskListTasks,
  #       where: task_list_tasks.project_id == ^project.id,
  #       select: task_list_tasks

  #   Repo.all(query) |> Repo.preload(:project)
  # end
end
