defmodule Dailyploy.Model.TaskListTasks do
  # import Ecto.Query
  alias Dailyploy.Repo
  alias Dailyploy.Schema.TaskListTasks
  alias Dailyploy.Model.Task

  def create(params) do
    changeset = TaskListTasks.changeset(%TaskListTasks{}, params)
    Repo.insert(changeset)
  end

  def delete(task_list_tasks) do
    Repo.delete(task_list_tasks)
  end

  def update(%TaskListTasks{} = task_list_tasks, params) do
    case task_list_tasks.task_id do
      nil ->
        changeset = TaskListTasks.changeset(task_list_tasks, params)
        Repo.update(changeset)

      _id ->
        task_list_tasks = Repo.preload(task_list_tasks, [:task])
        Task.update_task_list(task_list_tasks.task, params)
        changeset = TaskListTasks.changeset(task_list_tasks, params)
        Repo.update(changeset)
    end
  end

  def update_task_list(%TaskListTasks{} = task_list_tasks, params) do
    changeset = TaskListTasks.changeset(task_list_tasks, params)
    Repo.update(changeset)
  end

  # def get(id), do: Repo.get(TaskListTasks, id) |> Repo.preload([:owner, :category, :project_task_list])

  def get(id) when is_integer(id) do
    case Repo.get(TaskListTasks, id) do
      nil ->
        {:error, "not found"}

      task_list_tasks ->
        {:ok, task_list_tasks |> Repo.preload([:owner, :category, :task_lists, :task])}
    end
  end

  def move_task(task_list) do
    case Task.create_task_list(Map.from_struct(task_list) |> extract_params()) do
      {:ok, task} ->
        update(task_list, %{task_id: task.id})

      {:error, error} ->
        {:error, error}
    end
  end

  defp extract_params(params) do
    %{
      name: params.name,
      start_datetime: DateTime.utc_now(),
      end_datetime: DateTime.utc_now(),
      task_list_tasks_id: params.id,
      project_id: params.task_lists.project_id,
      owner_id: params.owner_id,
      category_id: params.category_id,
      status: params.status,
      estimation: params.estimation,
      priority: params.priority
    }
  end
end
