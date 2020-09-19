defmodule Dailyploy.Model.ProjectMember do
  alias Dailyploy.Repo
  alias Dailyploy.Schema.UserProject
  import Ecto.Query


  def get_project_member(user_ids, project_ids) do
    query =
      from projectuser in UserProject,
        where: projectuser.user_id in ^user_ids and projectuser.project_id in ^project_ids

    project_member_list = Repo.all(query)
    Enum.map(project_member_list, fn project_member -> %{project_member.user_id => project_member.project_id} end)
  end
end
