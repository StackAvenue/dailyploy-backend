defmodule DailyployWeb.ResourceProjectController do
  use DailyployWeb, :controller
  import Plug.Conn

  alias Dailyploy.Model.ResourceProject

  def index(conn, params) do
    IO.inspect(params)
    # projects = ResourceProject.fetch_projects(workspace_id)
    projects = ResourceProject.get_all(params)

    render(conn, "show.json", projects: projects)
  end

  # def get_all(%{page_size: page_size, page_number: page_number}, preloads, task_lists_id) do
  #   query =
  #     from checklist in RoadmapChecklist,
  #       where: checklist.task_lists_id == ^task_lists_id

  #   checklist_data =
  #     query |> order_by(:id) |> Repo.paginate(page: page_number, page_size: page_size)

  #   checklist_with_preloads = checklist_data.entries |> Repo.preload(preloads)
  #   paginated_response(checklist_with_preloads, checklist_data)
  # end

  # defp paginated_response(data, pagination_data) do
  #   %{
  #     entries: data,
  #     page_number: pagination_data.page_number,
  #     page_size: pagination_data.page_size,
  #     total_entries: pagination_data.total_entries,
  #     total_pages: pagination_data.total_pages
  #   }
  # end
end
