defmodule Dailyploy.Model.RoadmapChecklist do
  import Ecto.Query
  alias Dailyploy.Repo
  alias Dailyploy.Schema.RoadmapChecklist

  def create(params) do
    changeset = RoadmapChecklist.changeset(%RoadmapChecklist{}, params)
    Repo.insert(changeset)
  end

  @spec delete(%{__struct__: atom | %{__changeset__: any}}) :: any
  def delete(checklist) do
    Repo.delete(checklist)
  end

  def update(%RoadmapChecklist{} = checklist, params) do
    changeset = RoadmapChecklist.changeset(checklist, params)
    Repo.update(changeset)
  end

  # def get(id), do: Repo.get(RoadmapChecklist, id) |> Repo.preload([:project, :workspace, :creator])

  def get(id) when is_integer(id) do
    case Repo.get(RoadmapChecklist, id) do
      nil ->
        {:error, "not found"}

      checklist ->
        {:ok, checklist}
    end
  end

  def get_all(%{page_size: page_size, page_number: page_number}, preloads, task_lists_id) do
    query =
      from checklist in RoadmapChecklist,
        where: checklist.task_lists_id == ^task_lists_id

    checklist_data =
      query |> order_by(:id) |> Repo.paginate(page: page_number, page_size: page_size)

    checklist_with_preloads = checklist_data.entries |> Repo.preload(preloads)
    paginated_response(checklist_with_preloads, checklist_data)
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
