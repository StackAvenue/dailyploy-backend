defmodule Dailyploy.Model.TaskCategory do
  import Ecto.Query
  alias Dailyploy.Repo
  alias Dailyploy.Schema.TaskCategory

  def create(attrs \\ %{}) do
    %TaskCategory{}
    |> TaskCategory.changeset(attrs)
    |> Repo.insert()
  end

  def list_all_categories() do
    Repo.all(TaskCategory)
  end

  def update(task_category, params) do
    changeset = TaskCategory.changeset(task_category, params)
    Repo.update(changeset)
  end

  def query_already_existing_category(name) do
    query =
      from task_category in TaskCategory,
        where: task_category.name == ^name

    List.first(Repo.all(query))
  end

  def delete(task_category) do
    Repo.delete(task_category)
  end

  def get(id) when is_integer(id) do
    case Repo.get(TaskCategory, id) do
      nil ->
        {:error, "not found"}

      task_category ->
        {:ok, task_category}
    end
  end

  def task_summary_report_data(params) do
    task_ids = TaskModel.task_ids_for_criteria(params)
    total_estimated_time = TaskModel.total_estimated_time(task_ids)
    report_data = TaskModel.category_summary_report_data(task_ids)
    %{total_estimated_time: total_estimated_time, report_data: report_data}
  end
end
