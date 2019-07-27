defmodule Dailyploy.Model.TaskAssignee do
  alias Dailyploy.Repo
  alias Dailyploy.Schema.TaskAssignee


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
end
