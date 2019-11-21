defmodule Dailyploy.Model.Task do
  import Ecto.Query, only: [from: 2]

  alias Dailyploy.Repo
  alias Dailyploy.Schema.Task
  alias Dailyploy.Schema.Project
  alias Dailyploy.Schema.UserWorkspaceSetting
  alias Dailyploy.Schema.User

  def list_tasks(project_id) do
    query =
      from(task in Task,
        where: task.project_id == ^project_id,
        order_by: task.inserted_at
      )

    Repo.all(query)
  end

  def list_workspace_tasks(workspace_id) do
    project_query = from(project in Project, where: project.workspace_id == ^workspace_id, select: project.id)
    project_ids = Repo.all project_query

    task_query = from(task in Task, where: task.project_id in ^project_ids)
    Repo.all task_query
  end

  def list_workspace_user_tasks(workspace_id, user_id) do
    query =
      from task in Task,
      join: project in Project,
      on: task.project_id == project.id,
      where: project.workspace_id == ^workspace_id

    User
      |> Repo.get(user_id)
      |> Repo.preload([tasks: query])
      |> Map.fetch!(:tasks)
  end

  def list_workspace_user_tasks(workspace_id, user_id, start_date, end_date, project_ids) do
    query =
      case length(project_ids) == 0 do
        true ->
          from task in Task,
          join: project in Project,
          on: task.project_id == project.id,
          where: project.workspace_id == ^workspace_id and
            fragment("?::date", task.start_datetime) >= ^start_date and
            fragment("?::date", task.start_datetime) <= ^end_date

        false ->
          from task in Task,
          join: project in Project,
          on: task.project_id == project.id,
          where: project.workspace_id == ^workspace_id and
            task.project_id in ^project_ids and
            fragment("?::date", task.start_datetime) >= ^start_date and
            fragment("?::date", task.start_datetime) <= ^end_date
    end

    User
      |> Repo.get(user_id)
      |> Repo.preload([tasks: query])
      |> Map.fetch!(:tasks)
  end

  def get_details_of_task(user_workspace_setting_id, project_id) do
    query =
      from( task in Task,
      join: project in Project,
      on: task.project_id == ^project_id,
      join: userworkspacesettings in UserWorkspaceSetting,
      on: userworkspacesettings.id == ^user_workspace_setting_id and project.owner_id == userworkspacesettings.user_id
      )
    List.first(Repo.all(query))
  end

  def get_task!(id), do: Repo.get(Task, id)

  def create_task(attrs \\ %{}) do
    %Task{}
    |> Task.changeset(attrs)
    |> Repo.insert()
  end

  def update_task(task, attrs) do
    task
    |> Task.update_changeset(attrs)
    |> Repo.update()
  end

  def delete_task(task) do
    Repo.delete(task)
  end
end
