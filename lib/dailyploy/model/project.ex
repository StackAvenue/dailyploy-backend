defmodule Dailyploy.Model.Project do
  alias Dailyploy.Repo
  alias Dailyploy.Schema.Project
  alias Dailyploy.Model.ProjectUser, as: ProjectUserModel
  import Ecto.Query

  def list_projects() do
    Repo.all(Project)
  end

  def get_project!(id), do: Repo.get(Project, id)

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
    query = from project in Project, where: project.workspace_id == ^workspace_id and project.id == ^project_id
    List.first(Repo.all(query))
  end


  def get_user_by_project!(%{user_id: user_id, project_id: project_id}) do
    case ProjectUserModel.get_project!(%{user_id: user_id, project_id: project_id}, [:project]) do
      projectuser -> projectuser.project
      _ -> nil
    end
  end
end

