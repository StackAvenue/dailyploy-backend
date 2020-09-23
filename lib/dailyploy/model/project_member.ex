defmodule Dailyploy.Model.ProjectMember do
  alias Dailyploy.Repo
  alias Dailyploy.Schema.UserProject
  import Ecto.Query


  def get_project_member(user_ids, project_ids) do
    query =
      from projectuser in UserProject,
        where: projectuser.user_id in ^user_ids and projectuser.project_id in ^project_ids

    project_member_list = Repo.all(query)

    project_member_list
    |> Enum.group_by(&(&1.user_id))
    |> Enum.map(fn {key, value} -> %{key => value |> Enum.map(fn z -> z.project_id end)} end)
  end
end
