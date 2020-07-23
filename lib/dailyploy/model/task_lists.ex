defmodule Dailyploy.Model.TaskLists do
  import Ecto.Query
  alias Dailyploy.Repo
  alias Dailyploy.Schema.TaskLists

  def create(params) do
    changeset = TaskLists.changeset(%TaskLists{}, params)
    Repo.insert(changeset)
  end

  def delete(task_lists) do
    Repo.delete(task_lists)
  end

  def update(%TaskLists{} = task_lists, params) do
    changeset = TaskLists.changeset(task_lists, params)
    Repo.update(changeset)
  end

  # def get(id), do: Repo.get(TaskLists, id) |> Repo.preload([:project, :workspace, :creator])

  def get(id) when is_integer(id) do
    case Repo.get(TaskLists, id) do
      nil ->
        {:error, "not found"}

      task_lists ->
        {:ok, task_lists |> Repo.preload([:project, :workspace, :creator])}
    end
  end

  def get_all(%{page_size: page_size, page_number: page_number}, preloads, project_id) do
    query =
      from task_list in TaskLists,
        where: task_list.project_id == ^project_id

    task_lists_data =
      query |> order_by(:id) |> Repo.paginate(page: page_number, page_size: page_size)

    task_lists_with_preloads = task_lists_data.entries |> Repo.preload(preloads)
    paginated_response(task_lists_with_preloads, task_lists_data)
  end

  defp paginated_response(data, pagination_data) do
    %{
      entries: data,
      page_number: pagination_data.page_number,
      page_size: pagination_data.page_size,
      total_entries: pagination_data.total_entries,
      total_pages: pagination_data.total_pages
    }
  end
end
