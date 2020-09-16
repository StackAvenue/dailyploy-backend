defmodule Dailyploy.Model.Resource do
  alias Dailyploy.Repo
  alias Dailyploy.Schema.Project
  alias Dailyploy.Model.Project, as: ProjectModel
  alias Dailyploy.Model.User, as: UserModel
  alias Dailyploy.Schema.UserWorkspaceSetting
  alias Dailyploy.Schema.UserWorkspace
  alias Dailyploy.Schema.User

  import Ecto.Query

  # def list_projects() do
  #   Repo.all(Project)
  # end

  def fetch_data(workspace_id) do
    fetch_members(workspace_id)
    # fetch_project_members(workspace_id)
  end

  def fetch_projects(workspace_id) do
    # ProjectModel.list_projects()
    # ProjectModel.get_project_in_workspace(workspace_id)
    query =
      from project in Project,
        where: project.workspace_id == ^workspace_id,
        order_by: project.name

    Repo.all(query)
  end

  def fetch_members(workspace_id) do
    params = %{"workspace_id" => workspace_id}
    query_params = map_to_atom(params)

    # query =
    #   from(project in Project,
    #     where: project.workspace_id == ^query_params.workspace_id
    #   )
    #   |> Repo.preload(projects: query)

    members = filter_users(query_params)

    member_results =
      Enum.map(members, fn member ->
        user_workspace_setting =
          UserModel.list_user_workspace_setting(member.id, query_params.workspace_id)

        %{member: member}
      end)
  end

  def fetch_project_members(workspace_id) do
    params = %{"workspace_id" => workspace_id}
    query_params = map_to_atom(params)

    query =
      from(project in Project,
        where: project.workspace_id == ^query_params.workspace_id
      )


    # members = filter_users(query_params) |> Repo.preload(projects: query)
    members = filter_users(query_params)

    member_results =
      Enum.map(members, fn member ->
        user_workspace_setting =
          UserModel.list_user_workspace_setting(member.id, query_params.workspace_id)

        %{member: member}
      end)
      IO.inspect("ss", member_results)
  end


  defp map_to_atom(params) do
    IO.inspect(params)
    for {key, value} <- params, into: %{}, do: {String.to_atom(key), value}
  end

  defp filter_users(params) do
    query =
      from(user in User,
        join: user_workspace in UserWorkspace,
        on:
          user_workspace.user_id == user.id and
            user_workspace.workspace_id == ^params.workspace_id,
        distinct: true,
        order_by: user.name,
      )

    Repo.all(query)
  end

  # defp filter_where(params) do
  #   Enum.reduce(params, dynamic(true), fn
  #     {:workspace_id, workspace_id}, dynamic_query ->
  #       dynamic(
  #         [user, user_workspace, user_project, role],
  #         ^dynamic_query and user_workspace.workspace_id == ^workspace_id
  #       )

  #     {:user_ids, user_ids}, dynamic_query ->
  #       user_ids = Enum.map(String.split(user_ids, ","), fn x -> String.to_integer(x) end)

  #       dynamic(
  #         [user, user_workspace, user_project, role],
  #         (^dynamic_query and user.id in ^user_ids) or user_project.user_id in ^user_ids
  #       )

  #     {:project_ids, project_ids}, dynamic_query ->
  #       project_ids = Enum.map(String.split(project_ids, ","), fn x -> String.to_integer(x) end)

  #       dynamic(
  #         [user, user_workspace, user_project, role],
  #         ^dynamic_query and user_project.project_id in ^project_ids
  #       )

  #     {_, _}, dynamic_query ->
  #       dynamic_query
  #   end)
  # end
end
