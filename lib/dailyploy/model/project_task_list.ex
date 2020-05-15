defmodule Dailyploy.Model.ProjectTaskList do
  # import Ecto.Query
  alias Dailyploy.Repo
  alias Dailyploy.Schema.ProjectTaskList

  def create(params) do
    changeset = ProjectTaskList.changeset(%ProjectTaskList{}, params)
    Repo.insert(changeset)
  end

  def delete(project_task_list) do
    Repo.delete(project_task_list)
  end

  def update(%ProjectTaskList{} = project_task_list, params) do
    changeset = ProjectTaskList.changeset(project_task_list, params)
    Repo.update(changeset)
  end

  # def get(id), do: Repo.get(ProjectTaskList, id) |> Repo.preload([:project, :workspace, :creator])

  def get(id) when is_integer(id) do
    case Repo.get(ProjectTaskList, id) do
      nil ->
        {:error, "not found"}

      project_task_list ->
        {:ok, project_task_list |> Repo.preload([:project, :workspace, :creator])}
    end
  end

  # def get_all(project) do
  #   query =
  #     from project_task_list in ProjectTaskList,
  #       where: project_task_list.project_id == ^project.id,
  #       select: project_task_list

  #   Repo.all(query) |> Repo.preload(:project)
  # end
end
