defmodule Dailyploy.Model.TaskAssignee do
  alias Dailyploy.Repo
  alias Dailyploy.Schema.TaskAssignee

  def list_taskassignees() do
    Repo.all(TaskAssignee)
  end

  def get_taskassignee!(id), do: Repo.get(TaskAssignee, id)

  def create_taskassignee(attrs \\ %{}) do
    %TaskAssignee{}
    |> TaskAssignee.changeset(attrs)
    |> Repo.insert()
  end

  def update_task(taskassignee, attrs) do
    taskassignee
    |> TaskAssignee.changeset(attrs)
    |> Repo.update()
  end

  def delete_task(taskassignee) do
    Repo.delete(taskassignee)
  end
end
