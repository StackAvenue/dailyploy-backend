defmodule Dailyploy.Model.TaskAssignee do
  alias Dailyploy.Repo
  alias Dailyploy.Schema.TaskAssignee
  import Ecto.Query

  def list_task_assignees() do
    Repo.all(TaskAssignee)
  end

  def get_task_assignee!(id), do: Repo.get(TaskAssignee, id)

  def create_task_assignee(attrs \\ %{}) do
    %TaskAssignee{}
    |> TaskAssignee.changeset(attrs)
    |> Repo.insert()
  end

  def update_task_assignee(taskassignee, attrs) do
    taskassignee
    |> TaskAssignee.changeset(attrs)
    |> Repo.update()
  end

  def delete_task_assignee(taskassignee) do
    Repo.delete(taskassignee)
  end

  def get_user!(%{user_id: user_id, task_id: task_id}) do
    query =
      from taskassignee in TaskAssignee,
        where: taskassignee.user_id == ^user_id and taskassignee.task_id == ^task_id

    List.first(Repo.all(query))
  end

  def get_user!(%{user_id: user_id, task_id: task_id}, preloads) do
    query =
      from taskassignee in TaskAssignee,
        where: taskassignee.user_id == ^user_id and taskassignee.task_id == ^task_id

    taskassignee = List.first(Repo.all(query))
    Repo.preload(taskassignee, preloads)
  end
end
