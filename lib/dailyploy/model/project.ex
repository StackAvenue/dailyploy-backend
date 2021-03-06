defmodule Dailyploy.Model.Project do
  alias Dailyploy.Repo
  alias Dailyploy.Schema.Project
  alias Dailyploy.Schema.User
  alias Dailyploy.Schema.UserProject
  alias Dailyploy.Schema.UserWorkspaceSetting
  alias Dailyploy.Schema.UserTask
  alias Dailyploy.Schema.Task
  alias Dailyploy.Model.Task, as: TaskModel
  alias Dailyploy.Model.UserWorkspaceSetting, as: UWSModel
  import Ecto.Query

  def list_projects() do
    Repo.all(Project)
  end

  def task_summary_report_data(params) do
    task_ids = TaskModel.task_ids_for_criteria(params)
    # total_estimated_time = TaskModel.total_estimated_time(task_ids, params)
    total_capacity_time = UWSModel.capacity(params)
    capacity = capacity(params)
    report_data = TaskModel.project_summary_report_data(task_ids, params)
    %{total_estimated_time: total_capacity_time, report_data: report_data, capacity: capacity}
  end

  def list_projects_in_workspace(params) do
    query =
      Project
      |> join(:left, [project], user_project in UserProject,
        on: user_project.project_id == project.id
      )
      |> where(^filter_where(params))
      |> order_by(:id)
      |> distinct(true)

    Repo.all(query)
  end

  defp filter_where(params) do
    Enum.reduce(params, dynamic(true), fn
      {:workspace_id, workspace_id}, dynamic_query ->
        dynamic([project, user_project], ^dynamic_query and project.workspace_id == ^workspace_id)

      {:user_ids, user_ids}, dynamic_query ->
        user_ids = Enum.map(String.split(user_ids, ","), fn x -> String.to_integer(x) end)
        dynamic([project, user_project], ^dynamic_query and user_project.user_id in ^user_ids)

      {:project_ids, project_ids}, dynamic_query ->
        project_ids = Enum.map(String.split(project_ids, ","), fn x -> String.to_integer(x) end)
        dynamic([project, user_project], ^dynamic_query and project.id in ^project_ids)

      {_, _}, dynamic_query ->
        dynamic_query
    end)
  end

  def get_details_of_project(user_workspace_setting_id) do
    query =
      from(project in Project,
        join: userworkspacesettings in UserWorkspaceSetting,
        on:
          userworkspacesettings.id == ^user_workspace_setting_id and
            userworkspacesettings.user_id == project.owner_id and
            userworkspacesettings.workspace_id == project.workspace_id
      )

    List.first(Repo.all(query))
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

  def get_user_projects(project), do: Repo.preload(project, [:members, :owner])

  def get(id) when is_integer(id) do
    case Repo.get(Project, id) do
      nil ->
        {:error, "not found"}

      project ->
        {:ok, project}
    end
  end

  def extract_valid_project_ids(project_ids, workspace_id) do
    query =
      from project in Project,
        where: project.id in ^project_ids and project.workspace_id == ^workspace_id,
        select: project.id

    Repo.all(query)
  end

  def extract_project(project_ids) do
    query =
      from project in Project,
        where: project.id in ^project_ids

    Repo.all(query)
  end

  def extract_members(project_ids) do
    query =
      from project in Project,
        where: project.id in ^project_ids

    projects = Repo.all(query) |> Repo.preload([:members]) |> return_hash_list
  end

  defp return_hash_list(projects) do
    Enum.reduce(projects, %{}, fn project, acc ->
      member_ids = Enum.reduce(project.members, [], fn x, cc -> cc ++ [x.id] end)

      acc =
        case Map.has_key?(acc, project.id) do
          false -> Map.put_new(acc, project.id, member_ids)
          true -> acc
        end
    end)
  end

  def create_project(attrs \\ %{}) do
    %Project{}
    |> Project.changeset(attrs)
    |> Repo.insert()
  end

  def update_project(project, attrs) do
    project
    |> Project.update_changeset(attrs)
    |> Repo.update()
  end

  def delete_project(project_ids, workspace_id) do
    query =
      from project in Project,
        where: project.id in ^project_ids and project.workspace_id == ^workspace_id

    case Repo.delete_all(query) do
      {0, nil} -> {:error, "Project Not Found"}
      {_num, nil} -> {:ok, "Project Deleted Sucessfully "}
    end
  end

  def get_project_in_workspace!(%{workspace_id: workspace_id, project_id: project_id}) do
    query =
      from project in Project,
        where: project.workspace_id == ^workspace_id and project.id == ^project_id

    List.first(Repo.all(query))
  end

  def get_project_ids_in_workspace!(workspace_id) do
    query =
      from project in Project,
        where: project.workspace_id == ^workspace_id,
        select: project.id,
        distinct: true

    Repo.all(query)
  end

  def capacity(
        %{
          "start_date" => start_date,
          "end_date" => end_date,
          "user_ids" => user_ids,
          "workspace_id" => workspace_id
        } = params
      ) do
    user_ids = map_to_list(user_ids)

    query =
      from uwsetting in UserWorkspaceSetting,
        where: uwsetting.workspace_id == ^workspace_id and uwsetting.user_id in ^user_ids,
        select: sum(uwsetting.working_hours)

    result = Repo.one(query)
  end

  defp map_to_list(user_ids) do
    user_ids
    |> String.split(",")
    |> Enum.map(fn x -> String.to_integer(String.trim(x, " ")) end)
  end
end
