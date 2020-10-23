defmodule Dailyploy.Model.ResourceAllocation do
  alias Dailyploy.Repo

  alias Dailyploy.Schema.UserProject
  alias Dailyploy.Model.UserProject, as: UserProjectModel

  import Ecto.Query

  def delete_user_project(user_id, project_id) do
    query =
      from projectuser in UserProject,
        where: projectuser.user_id == ^user_id and projectuser.project_id == ^project_id

    user_project = List.first(Repo.all(query))

    UserProjectModel.delete_user_project(user_project)
  end
end
