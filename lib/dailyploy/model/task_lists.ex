defmodule Dailyploy.Model.TaskLists do
  # import Ecto.Query
  alias Dailyploy.Repo
  alias Dailyploy.Schema.TaskLists

  def create(params) do
    changeset = TaskLists.changeset(%TaskLists{}, params)
    Repo.insert(changeset)
  end

  def delete(task_list) do
    Repo.delete(task_list)
  end

  def update(%TaskLists{} = task_list, params) do
    changeset = TaskLists.changeset(task_list, params)
    Repo.update(changeset)
  end

  # def get(id), do: Repo.get(TaskLists, id) |> Repo.preload([:owner, :category, :project_task_list])

  def get(id) when is_integer(id) do
    case Repo.get(TaskLists, id) do
      nil ->
        {:error, "not found"}

      task_list ->
        {:ok, task_list |> Repo.preload([:owner, :category, :project_task_list])}
    end
  end

  # def get_all(project) do
  #   query =
  #     from task_list in TaskLists,
  #       where: task_list.project_id == ^project.id,
  #       select: task_list

  #   Repo.all(query) |> Repo.preload(:project)
  # end
end
