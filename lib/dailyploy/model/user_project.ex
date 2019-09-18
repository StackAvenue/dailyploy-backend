defmodule Dailyploy.Model.UserProject do
  alias Dailyploy.Repo
  alias Dailyploy.Schema.UserProject
  import Ecto.Query

  def list_user_projects() do
    Repo.all(UserProject)
  end

  def get_user_project!(id), do: Repo.get(UserProject, id)

  def create_user_project(attrs \\ %{}) do
    %UserProject{}
    |> UserProject.changeset(attrs)
    |> Repo.insert()
  end

  def update_user_project(projectuser, attrs) do
    projectuser
    |> UserProject.changeset(attrs)
    |> Repo.update()
  end

  def delete_user_project(projectuser) do
    Repo.delete(projectuser)
  end

  def get_project!(%{user_id: user_id, project_id: project_id}) do
    query =
      from projectuser in UserProject,
        where: projectuser.user_id == ^user_id and projectuser.project_id == ^project_id

    List.first(Repo.all(query))
  end

  def get_project!(%{user_id: user_id, project_id: project_id}, preloads) do
    query =
      from projectuser in UserProject,
        where: projectuser.user_id == ^user_id and projectuser.project_id == ^project_id

    projectuser = List.first(Repo.all(query))
    Repo.preload(projectuser, preloads)
  end
end
