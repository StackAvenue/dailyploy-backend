defmodule Dailyploy.Model.ResourceProject do
  alias Dailyploy.Repo
  alias Dailyploy.Schema.Project
  import Ecto.Query

  def get_all(params) do
    %{
      "page_size" => page_size,
      "page_number" => page_number,
      "workspace_id" => workspace_id
    } = params

    query =
      from project in Project,
        where: project.workspace_id == ^workspace_id,
        order_by: project.name

    paginated_project_data = Repo.paginate(query, page: page_number, page_size: page_size)
    paginated_response(paginated_project_data)
  end

  defp paginated_response(pagination_data) do
    %{
      entries: pagination_data.entries,
      page_number: pagination_data.page_number,
      page_size: pagination_data.page_size,
      total_entries: pagination_data.total_entries,
      total_pages: pagination_data.total_pages
    }
  end
end
