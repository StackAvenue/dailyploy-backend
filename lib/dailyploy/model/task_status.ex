defmodule Dailyploy.Model.TaskStatus do
  alias Dailyploy.Repo
  alias Dailyploy.Schema.TaskStatus

  def create(attrs \\ %{}) do
    %TaskStatus{}
    |> TaskStatus.changeset(attrs)
    |> Repo.insert()
  end

  # def list_all_categories() do
  #   Repo.all(TaskStatus)
  # end

  def update(task_category, params) do
    changeset = TaskStatus.changeset(task_category, params)
    Repo.update(changeset)
  end

  # def query_already_existing_category(name) do
  #   query =
  #     from task_category in TaskStatus,
  #       where: task_category.name == ^name

  #   List.first(Repo.all(query))
  # end

  def delete(task_category) do
    Repo.delete(task_category)
  end

  def get(id) when is_integer(id) do
    case Repo.get(TaskStatus, id) do
      nil ->
        {:error, "not found"}

      task_status ->
        {:ok, task_status}
    end
  end
end
