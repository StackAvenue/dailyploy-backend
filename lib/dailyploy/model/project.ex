defmodule Dailyploy.Model.Project do
  alias Dailyploy.Repo
  alias Dailyploy.Schema.Project
  alias Dailyploy.Schema.User
  alias Dailyploy.Schema.UserProject
  import Ecto.Query

  def list_projects() do
    Repo.all(Project)
  end

  def list_user_projects_in_workspace(%{workspace_id: workspace_id, user_id: user_id}) do
    query =
      from project in Project,
        join: user_project in UserProject,
        on: project.id == user_project.project_id,
        join: user in User,
        on: user.id == user_project.user_id,
        where: project.workspace_id == ^workspace_id and user_project.user_id == ^user_id

    Repo.all(query)
  end

  def load_user_project_in_workspace(%{
        workspace_id: workspace_id,
        user_id: user_id,
        project_id: project_id
      }) do
    query =
      from project in Project,
        join: user_project in UserProject,
        on: project.id == user_project.project_id,
        join: user in User,
        on: user.id == user_project.user_id,
        where:
          project.workspace_id == ^workspace_id and user_project.user_id == ^user_id and
            project.id == ^project_id

    List.first(Repo.all(query))
  end

  def get_project!(id), do: Repo.get(Project, id)

  def get_project!(id, preloads), do: Repo.get(Project, id) |> Repo.preload(preloads)

  def get_user_projects(project), do: Repo.preload(project, [:users])

  def create_project(attrs \\ %{}) do
    %Project{}
    |> Project.changeset(attrs)
    |> Repo.insert()
  end

  def update_project(project, attrs) do
    project
    |> Project.changeset(attrs)
    |> Repo.update()
  end

  def delete_project(project) do
    Repo.delete(project)
  end

  def get_project_in_workspace!(%{workspace_id: workspace_id, project_id: project_id}) do
    query =
      from project in Project,
        where: project.workspace_id == ^workspace_id and project.id == ^project_id

    List.first(Repo.all(query))
  end
end
