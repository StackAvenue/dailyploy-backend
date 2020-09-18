defmodule Dailyploy.Model.ResourceAllocation do
  alias Dailyploy.Repo
  alias Dailyploy.Schema.Project
  alias Dailyploy.Model.Project, as: ProjectModel
  alias Dailyploy.Model.User, as: UserModel
  alias Dailyploy.Schema.UserWorkspaceSetting
  alias Dailyploy.Schema.UserWorkspace
  alias Dailyploy.Schema.User
  alias Dailyploy.Schema.UserProject
  alias Dailyploy.Model.UserProject, as: UserProjectModel

  import Ecto.Query
  def fetch_project_members(workspace_id) do
    params = %{"workspace_id" => workspace_id}
    query_params = map_to_atom(params)

    query =
      from(project in Project,
        where: project.workspace_id == ^query_params.workspace_id,
        select: project.id
      )

    members = filter_users(query_params) |> Repo.preload(projects: query)

    member_results =
      Enum.map(members, fn member ->
        user_workspace_setting =
          UserModel.list_user_workspace_setting(member.id, query_params.workspace_id)

        %{member: member.id, projects: member.projects}
      end)

    member_projects(member_results)
  end

  def delete_user_project(user_id, project_id) do
    query =
      from projectuser in UserProject,
        where: projectuser.user_id == ^user_id and projectuser.project_id == ^project_id

    user_project = List.first(Repo.all(query))

    UserProjectModel.delete_user_project(user_project)
  end

  defp member_projects(member_results) do
    member_project_map = Enum.map(member_results, fn x -> %{x.member => x.projects} end)

    Enum.reduce(member_project_map, [], fn id, main ->
      [member_id] = Map.keys(id)
      [project_ids] = Map.values(id)

      main ++
        Enum.reduce(project_ids, [], fn project_id, acc ->
          acc ++ [%{member_id => project_id}]
        end)
    end)
  end

  defp map_to_atom(params) do
    for {key, value} <- params, into: %{}, do: {String.to_atom(key), value}
  end

  defp filter_users(params) do
    query =
      from(user in User,
        join: user_workspace in UserWorkspace,
        on:
          user_workspace.user_id == user.id and
            user_workspace.workspace_id == ^params.workspace_id,
        left_join: user_project in UserProject,
        on: user_project.user_id == user.id,
        where: ^filter_where(params),
        distinct: true,
        order_by: user.id
      )

    Repo.all(query)
  end

  defp filter_where(params) do
    Enum.reduce(params, dynamic(true), fn
      {:workspace_id, workspace_id}, dynamic_query ->
        dynamic(
          [user, user_workspace, user_project],
          ^dynamic_query and user_workspace.workspace_id == ^workspace_id
        )

      {:user_ids, user_ids}, dynamic_query ->
        user_ids = Enum.map(String.split(user_ids, ","), fn x -> String.to_integer(x) end)

        dynamic(
          [user, user_workspace, user_project],
          (^dynamic_query and user.id in ^user_ids) or user_project.user_id in ^user_ids
        )

      {:project_ids, project_ids}, dynamic_query ->
        project_ids = Enum.map(String.split(project_ids, ","), fn x -> String.to_integer(x) end)

        dynamic(
          [user, user_workspace, user_project],
          ^dynamic_query and user_project.project_id in ^project_ids
        )

      {_, _}, dynamic_query ->
        dynamic_query
    end)
  end
end
