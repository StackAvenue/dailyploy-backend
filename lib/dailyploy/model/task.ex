defmodule Dailyploy.Model.Task do
  import Ecto.Query

  alias Dailyploy.Repo
  alias Dailyploy.Schema.Task
  alias Dailyploy.Schema.Project
  alias Dailyploy.Schema.UserWorkspaceSetting
  alias Dailyploy.Schema.User
  alias Dailyploy.Schema.UserTask

  def list_tasks(project_id) do
    query =
      from(task in Task,
        where: task.project_id == ^project_id,
        order_by: task.inserted_at
      )

    Repo.all(query)
  end

  def list_workspace_tasks(workspace_id) do
    project_query =
      from(project in Project, where: project.workspace_id == ^workspace_id, select: project.id)

    project_ids = Repo.all(project_query)

    task_query = from(task in Task, where: task.project_id in ^project_ids)
    Repo.all(task_query)
  end

  def list_workspace_user_tasks(workspace_id, user_id) do
    query =
      from task in Task,
        join: project in Project,
        on: task.project_id == project.id,
        where: project.workspace_id == ^workspace_id

    User
    |> Repo.get(user_id)
    |> Repo.preload(tasks: query)
    |> Map.fetch!(:tasks)
  end

  def list_workspace_user_tasks(params) do
    query =
      Task
      |> join(:inner, [task], project in Project, on: task.project_id == project.id)
      # |> join(:inner, [task], user_task in UserTask, on: user_task.task_id == task.id)
      |> where(^filter_where(params))

    Repo.all(query)
  end

  def get_details_of_task(user_workspace_setting_id, project_id) do
    query =
      from(task in Task,
        join: project in Project,
        on: task.project_id == ^project_id,
        join: userworkspacesettings in UserWorkspaceSetting,
        on:
          userworkspacesettings.id == ^user_workspace_setting_id and
            project.owner_id == userworkspacesettings.user_id
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

  def get(id) when is_integer(id) do
    case Repo.get(Task, id) do
      nil ->
        {:error, "not found"}

      task ->
        {:ok, task}
    end
  end

  defp filter_where(params) do
    Enum.reduce(params, dynamic(true), fn
      {"workspace_id", workspace_id}, dynamic ->
        dynamic([task, project], ^dynamic and project.workspace_id == ^workspace_id)

      {"project_ids", project_ids}, dynamic ->
        project_ids =
          project_ids
          |> String.split(",")
          |> Enum.map(fn project_id -> String.trim(project_id) end)

        dynamic([task], ^dynamic and task.project_id in ^project_ids)

      {"start_date", start_date}, dynamic ->
        end_date = params["end_date"]

        dynamic(
          [task],
          (^dynamic and
             fragment("?::date BETWEEN ? AND ?", task.start_datetime, ^start_date, ^end_date)) or
            fragment("?::date BETWEEN ? AND ?", task.end_datetime, ^start_date, ^end_date) or
            fragment(
              "?::date <= ? AND ?::date >= ?",
              task.start_datetime,
              ^start_date,
              task.end_datetime,
              ^end_date
            )
        )

      {"user_ids", user_ids}, dynamic ->
        user_ids =
          user_ids
          |> String.split(",")
          |> Enum.map(fn user_id -> String.trim(user_id) end)

        dynamic([task, project], ^dynamic and task.owner_id in ^user_ids)

      {_, _}, dynamic ->
        dynamic
    end)
  end
end
