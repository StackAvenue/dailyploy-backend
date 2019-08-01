defmodule Dailyploy.Model.Task do
  alias Dailyploy.Repo
  alias Dailyploy.Schema.Task
  import Ecto.Query
  alias Dailyploy.Model.TaskAssignee, as: TaskAssigneeModel


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

  def get_user_by_task!(%{user_id: user_id, task_id: task_id}) do
    case TaskAssigneeModel.get_user!(%{user_id: user_id, task_id: task_id}) do
      taskassignee -> taskassignee.task
     _ ->  nil
    end
  end

  def get_task_in_project!(%{project_id: project_id, task_id: task_id}) do
    query = from task in Task, where: task.project_id == ^project_id and task.id == ^task_id
    List.first(Repo.all(query))
  end
end
