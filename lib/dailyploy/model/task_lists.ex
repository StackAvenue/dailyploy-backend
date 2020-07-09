defmodule Dailyploy.Model.TaskLists do
  # import Ecto.Query
  alias Dailyploy.Repo
  alias Dailyploy.Schema.TaskLists

  def create(params) do
    changeset = TaskLists.changeset(%TaskLists{}, params)
    Repo.insert(changeset)
  end

  def delete(task_lists) do
    Repo.delete(task_lists)
  end

  def update(%TaskLists{} = task_lists, params) do
    changeset = TaskLists.changeset(task_lists, params)
    Repo.update(changeset)
  end

  # def get(id), do: Repo.get(TaskLists, id) |> Repo.preload([:project, :workspace, :creator])

  def get(id) when is_integer(id) do
    case Repo.get(TaskLists, id) do
      nil ->
        {:error, "not found"}

      task_lists ->
        {:ok, task_lists |> Repo.preload([:project, :workspace, :creator])}
    end
  end

  # def get_all(project) do
  #   query =
  #     from task_lists in TaskLists,
  #       where: task_lists.project_id == ^project.id,
  #       select: task_lists

  #   Repo.all(query) |> Repo.preload(:project)
  # end
end
