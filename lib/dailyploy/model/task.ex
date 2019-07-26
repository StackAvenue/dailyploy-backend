defmodule Dailyploy.Model.Task do
  alias Dailyploy.Repo
  alias Dailyploy.Schema.Task

  def list_tasks() do
    Repo.all(Task)
  end

  def get_task!(id), do: Repo.get(Task, id)

  def create_task(attrs \\ %{}) do
    %Task{}
    |> Task.changeset(attrs)
    |> Repo.insert()
  end

  def update_task(task, attrs) do
    task
    |> Task.changeset(attrs)
    |> Repo.update()
  end

  def delete_task(task) do
    Repo.delete(task)
  end
end
