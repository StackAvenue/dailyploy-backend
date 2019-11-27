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
  
  def query_already_existing_category(name) do
    query =
      from task_category in TaskCategory,
      where: task_category.name == ^name

    List.first(Repo.all(query))  
  end

  def delete_task_category(task_category) do
    Repo.delete(task_category)
  end
  
end
