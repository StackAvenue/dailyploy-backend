defmodule Dailyploy.Model.ProjectUser do
  alias Dailyploy.Repo
  alias Dailyploy.Schema.ProjectUser
  import Ecto.Query


  def list_project_users() do
    Repo.all(ProjectUser)
  end

  def get_project_user!(id), do: Repo.get(ProjectUser, id)

  def create_project_user(attrs \\ %{}) do
    %ProjectUser{}
    |> ProjectUser.changeset(attrs)
    |> Repo.insert()
  end

  def update_project_user(projectuser, attrs) do
    projectuser
    |> ProjectUser.changeset(attrs)
    |> Repo.update()
  end

  def delete_project_user(projectuser) do
    Repo.delete(projectuser)
  end


  def get_project!(%{user_id: user_id, project_id: project_id}) do
    query =
      from projectuser in ProjectUser,
        where: projectuser.user_id == ^user_id and projectuser.project_id == ^project_id

    List.first(Repo.all(query))
  end

  def get_project!(%{user_id: user_id, project_id: project_id}, preloads) do
    query =
    from projectuser in ProjectUser,
        where: projectuser.user_id == ^user_id and projectuser.project_id == ^project_id

    projectuser = List.first(Repo.all(query))
    Repo.preload(projectuser, preloads)
  end
end
